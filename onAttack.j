/*
This is a generated trigger file for the event "onAttack", it triggers when a unit is damaged. It inputs the attacking unit as the one to do the ability cast.
*/

function Trig_onAttack_Conditions takes nothing returns boolean
    if ( not ( IsUnitType(GetEventDamageSource(), UNIT_TYPE_HERO) == true ) ) then
        return false
    endif
    if ( not ( GetPlayerController(GetOwningPlayer(GetEventDamageSource())) != MAP_CONTROL_USER ) ) then
        return false
    endif
    return true
endfunction

function Trig_onAttack_Actions takes nothing returns nothing
    call CastCustomAbilities(GetEventDamageSource())
endfunction

//===========================================================================
function InitTrig_onAttack takes nothing returns nothing
    set gg_trg_onAttack = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_onAttack, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_onAttack, Condition( function Trig_onAttack_Conditions ) )
    call TriggerAddAction( gg_trg_onAttack, function Trig_onAttack_Actions )
endfunction

