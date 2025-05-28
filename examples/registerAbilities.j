/*  
    This script is part of the CustomAiAbilitySystem 
    It is used to register abilities for the AI to use by giving the ability code, the ability target type as integer, the range to check for nearby enemies and he ability orderId
    // These are the types of targets that can be used with the custom abilities
    public constant integer TARGET_TYPE_POINT = 1
    public constant integer TARGET_TYPE_AREA = 2
    public constant integer TARGET_TYPE_UNIT = 3
    public constant integer TARGET_TYPE_NO_TARGET = 4
*/
function Trig_registerAbilities_Actions takes nothing returns nothing
    call RegisterCustomAbility('A020',4,500,"avatar")
    call RegisterCustomAbility('A03V',4,500,"roar")
    call RegisterCustomAbility('A04T',4,500,"roar")
    call RegisterCustomAbility('A02X',4,300,"battleroar")
    call RegisterCustomAbility('A04P',4,300,"raisedead")
    call RegisterCustomAbility('ANab',3,400,"acidbomb")
    call RegisterCustomAbility('A04N',1,300,"carrionswarm")
    call RegisterCustomAbility('A001',1,1000,"flare")
endfunction

//===========================================================================
function InitTrig_registerAbilities takes nothing returns nothing
    set gg_trg_registerAbilities = CreateTrigger(  )
    call TriggerRegisterTimerEventSingle( gg_trg_registerAbilities, 5 )
    call TriggerAddAction( gg_trg_registerAbilities, function Trig_registerAbilities_Actions )
endfunction

