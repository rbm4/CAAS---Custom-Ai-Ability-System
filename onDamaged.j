function Trig_onDamaged_Conditions takes nothing returns boolean
    if ( udg_customAiHeroControl and not ( IsUnitType(BlzGetEventDamageTarget(), UNIT_TYPE_HERO) == true ) ) then
        return false
    endif
    if ( udg_customAiPlayerController ) then
	return true
    endif
    if ( not ( GetPlayerController(GetOwningPlayer(BlzGetEventDamageTarget())) != MAP_CONTROL_USER ) ) then
        return false
    endif
    return true
endfunction

function Trig_onDamaged_Actions takes nothing returns nothing 
    call CastCustomAbilities(BlzGetEventDamageTarget())
endfunction

//===========================================================================
function InitTrig_onDamaged takes nothing returns nothing
    set gg_trg_onDamaged = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_onDamaged, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_onDamaged, Condition( function Trig_onDamaged_Conditions ) )
    call TriggerAddAction( gg_trg_onDamaged, function Trig_onDamaged_Actions )
endfunction

