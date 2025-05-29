library CustomAiAbilitySystem /* version 0.1
    *************************************************************************************
    *
    *   ------------
    *   Description:
    *   ------------
    *   A lightweight system that aims to control conditionals for units in general to use a myriad of custom abilities from any
    *   different types of abilities. Initially designed for AI heroes in my custom map, but can be used for any unit.
    *   By Ricardo (darkprofeta).
    *   This library is also a final course work for my Computer Science degree, the system was made inside my custom map
    *   and improved in many ways to be more flexible and useful for any type of map and used as submission for the course. 
    *
    *   -------------------
    *   Usage instruction:
    *   -------------------
    *   The system will need for you to inform the ability ID, target type, cast range and order ID for each custom 
    *   ability you want to register, do not use the same orderId for a given unit and avoid changing the original orderId
    *   of the abilities you want to register.
    *   A good way to test the system is for you to have an player-controlled unit to have it cast an ability on the 
    *   onDamage event, if an ability is not being cast you may want to double-check if you informed the correct target type
    *   or conditionals for the ability. 
    *   Take your time and test one ability at a time.
    *
    *   ---------
    *   Features:
    *   ---------
    *   - Allows you register an unit-type, ability ID, target type, range and order ID for a custom ability to be controlled
    *   - Many GUI friendly triggers that represent each type of usage for the custom abilities
    *   - Allows to control conditionals like how much healthpoints or mana to decide whether to use abilities or not
    *   - Allows to control how many enemies are nearby to decide whether to use abilities or not
    *   - Allows to control if ability will be cast in a random target or the current target
    *   - onAttack, onAttacked, onAcquireRange, onPeriod are some of the supported events
    *   ----
    *   API:
    *   ----
    *   function RegisterCustomAbility(integer abilityId, integer targetType, real castRange, string orderId)
    *     - Register a custom ability with the system, must be called on the initialization of the map ideally to register
    *    every use case of the custom abilities, many examples are shown on the examples folder.
    *
    *   function CastCustomAbilities(unit aiHero) -> Returns a boolean value
    *     - Function that will cast the custom abilities registered for the aiHero unit 
    *    (doesn't actually requires the unit to be an hero, can be any unit)
    *
    *   function IsAbilityOnCooldown(unit whichUnit) -> Returns a boolean value
    *     - Check if the a given ability is on cooldown for a unit
    *
    *   function IsEnemyUnitAlive() -> Returns a boolean value
    *     - Check if the unit is an enemy and alive
    *
    *   function RegisterUnitType(unit whichUnit) -> Returns a boolean value
    *     - Register a unit type to be used with the system
    *
    *
    *   --------------
    *      requires 
    *   --------------
    *   CustomAiAbilitySystem has no requirements whatsoever.
    *
    *
    *   -------------------
    *   Import instruction:
    *   -------------------
    *   Simply copy and paste the Custom Ai Ability System folder into your map.
    *   I personally recommend you to take a look at the examples folder to see how to use the system properly
    *
    *   ---------------------
    *   Global configuration:
    *   ---------------------
    */
    globals
        // These are the types of targets that can be used with the custom abilities
        public constant integer TARGET_TYPE_POINT = 1           // Target type for point abilities
        public constant integer TARGET_TYPE_AREA = 2            // Target type for area abilities
        public constant integer TARGET_TYPE_UNIT = 3            // Target type for unit abilities
        public constant integer TARGET_TYPE_NO_TARGET = 4       // Target type for abilities that do not require a target
        public constant integer TARGET_TYPE_UNIT_ALLY = 5       // Target type for abilities that target allied units
        public constant integer TARGET_TYPE_SELF = 6            // Target type for abilities that target the unit itself
        integer array udg_registeredAbilities // Array to store registered ability IDs
        integer array udg_registeredUnitTypes // Array to store registered unit types
        //udg_customAiAbility               // Global Variable for GUI-friendly usage
        //udg_customAiAbilityTargetType     // Global Variable for GUI-friendly usage
        //udg_customAiUnitType              // Global Variable for GUI-friendly usage
        //udg_customAiHeroAbility           // Global Variable for GUI-friendly usage
		
    endglobals

    // Helper function to check if a unit is an enemy and alive
    function IsEnemyUnitAlive takes nothing returns boolean
        return IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(udg_customAiHeroAbility)) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
    endfunction

    // Helper function to check if a unit is an ally
    function IsUnitAllyAlive takes nothing returns boolean
        return IsUnitAlly(GetFilterUnit(), GetOwningPlayer(udg_customAiHeroAbility)) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
    endfunction

    // Helper to check if ability is on cooldown, used to avoid triggering abilities that are not ready and prevent resource waste
    function IsAbilityOnCooldown takes unit u, integer abilityId returns boolean
        return BlzGetUnitAbilityCooldownRemaining(u, abilityId) > 0
    endfunction

    // Function to register a custom ability
    function RegisterCustomAbility takes integer abilityId, integer targetType, real castRange, string orderId returns nothing
        local integer index = udg_registeredAbilityCount
        set udg_registeredAbilities[index] = abilityId
        set udg_registeredAbilityCount = udg_registeredAbilityCount + 1
        

        call SaveInteger(udg_customAiAbilitiesHash, abilityId, 0, targetType) // Save target type
        call SaveReal(udg_customAiAbilitiesHash, abilityId, 1, castRange)    // Save cast range
        call SaveStringBJ(orderId, 2, abilityId, udg_customAiAbilitiesHash)    // Save orderId
    endfunction

    function RegisterUnitType takes nothing returns nothing
        local integer unitTypeId = udg_customAiUnitType
        local integer index = udg_customAiTypeCount
        local integer result

        set udg_registeredUnitTypes[index] = unitTypeId
        set udg_customAiTypeCount = udg_customAiTypeCount + 1
        call SaveInteger(udg_customAiUnitTypesHash, unitTypeId, 0, 1)

        set result = LoadInteger(udg_customAiUnitTypesHash, unitTypeId, 0)
    endfunction
    
    
    // Function to cast custom abilities
    function CastCustomAbilities takes unit aiHero returns boolean
        local integer i = 0
        local integer abilityId
        local integer targetType
        local real castRange
        local group nearbyEnemies
        local unit targetUnit
        local location targetPoint
        local boolean abilityUsed = false
        local string orderId
        local integer result

        if(udg_customAiUnitTypeControl) then
            // Check if the unit type is registered
            set result = LoadInteger(udg_customAiUnitTypesHash, GetUnitTypeId(aiHero), 0)
            if result == 0 then
                return false
            endif
        endif
        //call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "casting ability")


        // Loop through registered abilities
        loop
            exitwhen i >= udg_registeredAbilityCount
            set abilityId = udg_registeredAbilities[i]
            set udg_customAiHeroAbility = aiHero

            // Check if the hero has the ability
            if GetUnitAbilityLevel(aiHero, abilityId) > 0  then
                set targetType = LoadInteger(udg_customAiAbilitiesHash, abilityId, 0)
                set castRange = LoadReal(udg_customAiAbilitiesHash, abilityId, 1)
                set orderId = LoadStringBJ(2, abilityId, udg_customAiAbilitiesHash)

                if targetType == TARGET_TYPE_UNIT then
                    // Find a nearby enemy unit within cast range
                    set nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, GetUnitLoc(aiHero), Condition(function IsEnemyUnitAlive))
                    set targetUnit = FirstOfGroup(nearbyEnemies)
                    if targetUnit != null then
                        call IssueTargetOrderBJ(aiHero, orderId, targetUnit )
                        set abilityUsed = true
                        exitwhen false
                    endif
                    call DestroyGroup(nearbyEnemies)
                elseif targetType == TARGET_TYPE_POINT then
                    // Cast at a point within range
                    set nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, GetUnitLoc(aiHero), Condition(function IsEnemyUnitAlive))
                    set targetUnit = FirstOfGroup(nearbyEnemies)
                    if targetUnit != null then
                        set targetPoint = GetUnitLoc(targetUnit)
                        call IssuePointOrderLocBJ(aiHero, orderId, targetPoint )
                        call RemoveLocation(targetPoint)
                        set abilityUsed = true
                        exitwhen false
                    endif
                    call DestroyGroup(nearbyEnemies)
                elseif targetType == TARGET_TYPE_AREA then
                    // Cast at a random area with enemies
                    set nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, GetUnitLoc(targetUnit), Condition(function IsEnemyUnitAlive))
                    set targetUnit = FirstOfGroup(nearbyEnemies)
                    if targetUnit != null then
                        set targetPoint = GetUnitLoc(targetUnit)
                        call IssuePointOrderLocBJ(aiHero, orderId, targetPoint )
                        call RemoveLocation(targetPoint)
                        set abilityUsed = true
                        exitwhen false
                    endif
                    call DestroyGroup(nearbyEnemies)
                elseif targetType == TARGET_TYPE_NO_TARGET then
                    // Check for at least 2 nearby enemies before casting
                    set nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, GetUnitLoc(aiHero), Condition(function IsEnemyUnitAlive))
                    if CountUnitsInGroup(nearbyEnemies) >= 1 then
                        call IssueImmediateOrderBJ(aiHero, orderId )
                        set abilityUsed = true
                        exitwhen false
                    endif
                    call DestroyGroup(nearbyEnemies)
                elseif targetType == TARGET_TYPE_UNIT_ALLY then
                    // Find a nearby random ally unit within cast range
                    set nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, GetUnitLoc(aiHero), Condition(function IsUnitAllyAlive))
                    set targetUnit = FirstOfGroup(nearbyEnemies)
                    if targetUnit != null then
                        call IssueTargetOrderBJ(aiHero, orderId, targetUnit )
                        set abilityUsed = true
                        exitwhen false
                    endif
                    call DestroyGroup(nearbyEnemies)
                elseif targetType == TARGET_TYPE_SELF then
                    call IssueTargetOrderBJ(aiHero, orderId, aiHero )
                    set abilityUsed = true
                endif
            endif

            set i = i + 1
        endloop

        return abilityUsed
    endfunction 
endlibrary


