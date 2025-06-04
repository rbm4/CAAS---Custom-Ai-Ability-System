function Trig_onAcquiresTarget_Conditions takes nothing returns boolean
    if ( udg_customAiHeroControl and not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true ) ) then
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

function OnTargetAcquire takes nothing returns nothing
    //call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Target acquired: " + I2S(GetHandleId(GetTriggerUnit())))
    call CastCustomAbilities(GetTriggerUnit())
endfunction

function onAcquiresTarget_UnitDies takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer uid = GetHandleId(u)
    local trigger t_acquire = LoadTriggerHandle(udg_onAcquiresTarget_Hashtable, uid, 0)
    local trigger t_death = LoadTriggerHandle(udg_onAcquiresTarget_Hashtable, uid, 1)
    

    // Destroy the triggers associated with this unit
    if t_acquire != null then
        call DestroyTrigger(t_acquire)
    endif
    if t_death != null then
        call DestroyTrigger(t_death)
    endif

    // Remove the unit from the hashtable
    call FlushChildHashtable(udg_onAcquiresTarget_Hashtable, uid)

    set u = null
    set t_acquire = null
    set t_death = null
endfunction

function Trig_onAcquiresTarget_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer uid = GetHandleId(u)
    local trigger t_acquire = CreateTrigger()
    local trigger t_death = CreateTrigger()
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Initializing onAcquireTarget. " )

    // Register the acquired target event for this unit
    call TriggerRegisterUnitEvent(t_acquire, u, EVENT_UNIT_ACQUIRED_TARGET)
    // Add your custom actions for acquired target here, e.g.:
    call TriggerAddAction(t_acquire, function OnTargetAcquire)

    // Store the trigger in the hashtable
    call SaveTriggerHandle(udg_onAcquiresTarget_Hashtable, uid, 0, t_acquire)

    // Register the death event for this unit
    call TriggerRegisterUnitEvent(t_death, u, EVENT_UNIT_DECAY)
    call TriggerAddAction(t_death, function onAcquiresTarget_UnitDies)

    // Store the death trigger in the hashtable
    call SaveTriggerHandle(udg_onAcquiresTarget_Hashtable, uid, 1, t_death)

    set u = null
    set t_acquire = null
    set t_death = null

endfunction

//===========================================================================
function InitTrig_onAcquiresTarget takes nothing returns nothing
    set gg_trg_onAcquiresTarget = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_onAcquiresTarget, GetPlayableMapRect() )
    call TriggerAddCondition( gg_trg_onAcquiresTarget, Condition( function Trig_onAcquiresTarget_Conditions ) )
    call TriggerAddAction( gg_trg_onAcquiresTarget, function Trig_onAcquiresTarget_Actions )
endfunction

