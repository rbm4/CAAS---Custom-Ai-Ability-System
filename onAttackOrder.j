function Trig_onAttackOrder_Conditions takes nothing returns boolean
    if ( udg_customAiHeroControl and not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true ) ) then
        return false
    endif
    if ( not ( GetIssuedOrderIdBJ() == String2OrderIdBJ("attack") ) ) then
        return false
    endif
    if ( udg_customAiPlayerController ) then
	return true
    endif
    if ( not ( GetPlayerController(GetOwningPlayer(GetTriggerUnit())) != MAP_CONTROL_USER ) ) then
        return false
    endif
    return true
endfunction
function Trig_onAttackOrder_TimerCallback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local unit u = LoadUnitHandle(udg_customAiAbilitiesHash, GetHandleId(t), 0)
    local location loc = LoadLocationHandle(udg_customAiAbilitiesHash, GetHandleId(t), 1)

    call DisableTrigger( gg_trg_onAttackOrder )
    // Only issue the order if the unit is idle (order id 0)
    if GetUnitCurrentOrder(u) == 0 then
        call IssuePointOrderLocBJ(u, "attack", loc)
    endif
    call RemoveLocation(loc)
    call FlushChildHashtable(udg_customAiAbilitiesHash, GetHandleId(t))
    call DestroyTimer(t)
    call EnableTrigger( gg_trg_onAttackOrder )

    set u = null
    set loc = null
    set t = null
endfunction

function Trig_onAttackOrder_Actions takes nothing returns nothing
    local unit u = GetOrderedUnit()
    local location loc = GetOrderPointLoc()
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    call DisableTrigger(GetTriggeringTrigger())
    //call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "onAttackOrder - cast: " + I2S(GetHandleId(u)))
    call CastCustomAbilities(u)
    // Save unit and location for timer callback
    call SaveUnitHandle(udg_customAiAbilitiesHash, id, 0, u)
    call SaveLocationHandle(udg_customAiAbilitiesHash, id, 1, loc)
    call TimerStart(t, 0.5, false, function Trig_onAttackOrder_TimerCallback)
    call EnableTrigger(GetTriggeringTrigger())
    set u = null
    set loc = null
    set t = null
endfunction

//===========================================================================
function InitTrig_onAttackOrder takes nothing returns nothing
    set gg_trg_onAttackOrder = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_onAttackOrder, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
    call TriggerAddCondition( gg_trg_onAttackOrder, Condition( function Trig_onAttackOrder_Conditions ) )
    call TriggerAddAction( gg_trg_onAttackOrder, function Trig_onAttackOrder_Actions )
endfunction

