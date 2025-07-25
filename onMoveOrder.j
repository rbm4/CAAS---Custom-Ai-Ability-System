function Trig_onMoveOrder_Conditions takes nothing returns boolean
    if ( udg_customAiHeroControl and not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true ) ) then
        return false
    endif
    if ( not ( GetIssuedOrderIdBJ() == String2OrderIdBJ("smart") or GetIssuedOrderIdBJ() == String2OrderIdBJ("move") ) ) then
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
function Trig_onMoveOrder_TimerCallback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local unit u = LoadUnitHandle(udg_customAiAbilitiesHash, GetHandleId(t), 0)
    local location loc = LoadLocationHandle(udg_customAiAbilitiesHash, GetHandleId(t), 1)

    

    call DisableTrigger( gg_trg_onMoveOrder )
    // Only issue the order if the unit is idle (order id 0)
    if GetUnitCurrentOrder(u) == 0 then
        call IssuePointOrderLocBJ(u, "move", loc)
    endif
    call RemoveLocation(loc)
    call FlushChildHashtable(udg_customAiAbilitiesHash, GetHandleId(t))
    call DestroyTimer(t)
    call EnableTrigger( gg_trg_onMoveOrder )



    set u = null
    set loc = null
    set t = null
endfunction

function Trig_onMoveOrder_Actions takes nothing returns nothing
    local unit u = GetOrderedUnit()
    local location loc = GetOrderPointLoc()
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    
    call CastCustomAbilities(u,udg_ON_MOVE_ORDER_EVENT)
    // Save unit and location for timer callback
    //call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "OnMoveOrder. " )
    call SaveUnitHandle(udg_customAiAbilitiesHash, id, 0, u)
    call SaveLocationHandle(udg_customAiAbilitiesHash, id, 1, loc)
    call TimerStart(t, 0.8, false, function Trig_onMoveOrder_TimerCallback)
    
    set u = null
    set loc = null
    set t = null
endfunction

//===========================================================================
function InitTrig_onMoveOrder takes nothing returns nothing
    set gg_trg_onMoveOrder = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_onMoveOrder, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
    call TriggerAddCondition( gg_trg_onMoveOrder, Condition( function Trig_onMoveOrder_Conditions ) )
    call TriggerAddAction( gg_trg_onMoveOrder, function Trig_onMoveOrder_Actions )
endfunction

