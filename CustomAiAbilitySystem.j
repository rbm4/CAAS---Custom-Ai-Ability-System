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
        // These aim to control debug messages for you to check in detail what's happening in the code
        private constant boolean isDebuggingCustomAi = false	// This property will spam A LOT of text on the screen, use it in controlled environments, ideally testing one event at a time
        // These are the types of targets that can be used with the custom abilities
        public constant integer TARGET_TYPE_POINT = 1                           // Target type for point abilities
        public constant integer TARGET_TYPE_AREA = 2                            // Target type for area abilities
        public constant integer TARGET_TYPE_UNIT = 3                            // Target type for unit abilities
        public constant integer TARGET_TYPE_NO_TARGET = 4                       // Target type for abilities that do not require a target
        public constant integer TARGET_TYPE_UNIT_ALLY = 5                       // Target type for abilities that target allied units
        public constant integer TARGET_TYPE_SELF = 6                            // Target type for abilities that target the unit itself
        public constant integer TARGET_TYPE_NO_TARGET_DEAD_CHECK = 7            // Target type for abilities that look for dead units nearby, like animate dead
        public constant integer TARGET_TYPE_NO_TARGET_DEAD_CHECK_ALLY = 8 		// Target type for abilities that look for dead units nearby, but only for friendly units
        private constant string ORDER_ID_NONE = "none" // Default order ID for no target abilities
        private constant string ORDER_ID_STOP = "stop"
        private constant string ORDER_ID_MOVE = "move"
        private constant string ORDER_ID_ATTACK = "attack"
        private constant string ORDER_ID_PATROL = "patrol"
        private constant string ORDER_ID_SMART = "smart"
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

    // Helper function to check if a unit is an ally and it is not the unit to cast the ability
    function IsUnitAllyAlive takes nothing returns boolean
        return GetFilterUnit() != udg_customAiHeroAbility and IsUnitAlly(GetFilterUnit(), GetOwningPlayer(udg_customAiHeroAbility)) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
    endfunction

    function IsUnitDeadAlly takes nothing returns boolean
        return GetFilterUnit() != udg_customAiHeroAbility and IsUnitAlly(GetFilterUnit(), GetOwningPlayer(udg_customAiHeroAbility)) and IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
    endfunction
    
    function IsUnitDead takes nothing returns boolean
        return GetFilterUnit() != udg_customAiHeroAbility and IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
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

    function RegisterCustomAbilityWrapper takes nothing returns boolean
        // This function is a wrapper to allow GUI users to register custom abilities
        local integer abilityRef = udg_customAiRegisterAbility
        local integer targetType = udg_customAiRegisterAbilityTType
        local real castRange = udg_customAiRegisterAbilityRange
        local string orderId = udg_customAiRegisterAbilityOrderId
        local boolean isRandom = udg_customAiRegisterAbilityRand
        local integer mana = udg_customAiRegisterAbilityMana
        local integer hp = udg_customAiRegisterAbilityHp
        local integer enemies = udg_customAiRegisterAbilityEnem
        local integer index = udg_registeredAbilityCount

        // Check if the ability is already registered
        if LoadInteger(udg_customAiAbilitiesHash, abilityRef, 0) != 0 then
            // Ability already registered, exit
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "ERROR! Ability already registered: " + I2S(abilityRef))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "This library does not allow registering the same ability more than once. to change the behaviour of an ability, you must use the update method. Registering an ability twice will cause unintended behaviour or conflicts with the intended behaviour.")
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "This is probably caused by making a mistake in the GUI, please check your GUI code and make sure you are not trying to register the same ability twice.")
            return false
        endif    

        set udg_registeredAbilities[index] = abilityRef
        set udg_registeredAbilityCount = udg_registeredAbilityCount + 1

        call SaveInteger(udg_customAiAbilitiesHash, abilityRef, 0, targetType)
        call SaveReal(udg_customAiAbilitiesHash, abilityRef, 1, castRange)
        call SaveStr(udg_customAiAbilitiesHash, abilityRef, 2, orderId)
        call SaveBoolean(udg_customAiAbilitiesHash, abilityRef, 3, isRandom)
        call SaveInteger(udg_customAiAbilitiesHash, abilityRef, 4, mana)
        call SaveInteger(udg_customAiAbilitiesHash, abilityRef, 5, hp)
        call SaveInteger(udg_customAiAbilitiesHash, abilityRef, 6, enemies)

        return true
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
    
    function ResetOrderCd takes nothing returns nothing
        local integer aiHeroId = LoadInteger(udg_customAiUnitTypesHash, GetHandleId(GetExpiredTimer()), 0)
        call SaveBoolean(udg_customAiUnitTypesHash, aiHeroId, 1, false)
        call DestroyTimer(GetExpiredTimer())
    endfunction

    function GetClosestUnitInGroup takes unit source, group nearbyEnemies returns unit
        local unit targetUnit = null
        local real minDist = 99999999.0
        local real dist
        local group g = nearbyEnemies
        local unit u = FirstOfGroup(g)
        local real x1 = GetUnitX(source)
        local real y1 = GetUnitY(source)
        local integer count = 0

        if isDebuggingCustomAi then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GetClosestUnitInGroup: Starting search for closest unit.")
        endif

        loop
            exitwhen u == null
            set count = count + 1
            set dist =(GetUnitX(u) - x1) *(GetUnitX(u) - x1) +(GetUnitY(u) - y1) *(GetUnitY(u) - y1)
            if isDebuggingCustomAi then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Checking unit #" + I2S(count) + ": " + GetUnitName(u) + " at (" + R2S(GetUnitX(u)) + ", " + R2S(GetUnitY(u)) + "), dist^2 = " + R2S(dist))
            endif
            if dist < minDist then
                set minDist = dist
                set targetUnit = u
                if isDebuggingCustomAi then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "New closest unit: " + GetUnitName(u) + " (dist^2 = " + R2S(dist) + ")")
                endif
            endif
            call GroupRemoveUnit(g, u)
            set u = FirstOfGroup(g)
        endloop

        if isDebuggingCustomAi then
            if targetUnit != null then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GetClosestUnitInGroup: Closest unit found: " + GetUnitName(targetUnit) + " at (" + R2S(GetUnitX(targetUnit)) + ", " + R2S(GetUnitY(targetUnit)) + ")")
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GetClosestUnitInGroup: No unit found in group (returning null).")
            endif
        endif

        return targetUnit
    endfunction

    // Picks a random unit from a group using Reservoir Sampling
    function GroupPickRandomUnitCustom takes group g returns unit
        local unit picked = null
        local unit u
        local integer count = 0
        local integer r
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            set count = count + 1
            if isDebuggingCustomAi then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GroupPickRandomUnitCustom: Checking unit #" + I2S(count) + " (" + GetUnitName(u) + ")")
            endif
            if GetRandomInt(1, count) == 1 then
                set picked = u
                if isDebuggingCustomAi then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GroupPickRandomUnitCustom: Picked unit changed to: " + GetUnitName(picked))
                endif
            endif
            call GroupRemoveUnit(g, u)
        endloop
        if isDebuggingCustomAi then
            if picked != null then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GroupPickRandomUnitCustom: Final picked unit: " + GetUnitName(picked))
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GroupPickRandomUnitCustom: No unit picked (group empty)")
            endif
        endif
        return picked
    endfunction

    // Helper function to process no-target dead ally abilities
    // used for abilities like Resurrection that require dead allies to be present
    function ProcessNoTargetDeadAllyAbility takes unit aiHero, real castRange, location heroLoc, string orderId, integer enemies returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsUnitDeadAlly))
        local boolean abilityUsed = false

        if CountUnitsInGroup(nearbyEnemies) >= enemies then
            call IssueImmediateOrderBJ(aiHero, orderId)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction

    // Helper function to process no-target dead enemy abilities
    // used for abilities like Animate Dead that require dead units to be present
    function ProcessNoTargetDeadEnemyAbility takes unit aiHero, real castRange, location heroLoc, string orderId, integer enemies returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsUnitDead))
        local boolean abilityUsed = false

        if CountUnitsInGroup(nearbyEnemies) >= enemies then
            call IssueImmediateOrderBJ(aiHero, orderId)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction

    // Helper function to process self-target abilities that require dead units nearby
    function ProcessSelfTargetDeadNearbyAbility takes unit aiHero, real castRange, location heroLoc, string orderId, integer enemies returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsUnitDead))
        local boolean abilityUsed = false

        if CountUnitsInGroup(nearbyEnemies) >= enemies then
            call IssueTargetOrderBJ(aiHero, orderId, aiHero)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction

    // Helper function to process unit-ally target abilities
    function ProcessUnitAllyTargetAbility takes unit aiHero, real castRange, location heroLoc, string orderId, boolean isRandom returns boolean
        local group nearbyAllies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsUnitAllyAlive))
        local unit targetUnit
        local boolean abilityUsed = false

        if not isRandom then
            set targetUnit = GetClosestUnitInGroup(aiHero, nearbyAllies)
        else
            set targetUnit = GroupPickRandomUnitCustom(nearbyAllies)
        endif

        if targetUnit != null then
            call IssueTargetOrderBJ(aiHero, orderId, targetUnit)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyAllies)
        return abilityUsed
    endfunction


    // Helper function to process no-target abilities that require at least nearby enemy units
    function ProcessNoTargetEnemyNearbyAbility takes unit aiHero, real castRange, location heroLoc, string orderId returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsEnemyUnitAlive))
        local boolean abilityUsed = false

        if CountUnitsInGroup(nearbyEnemies) >= 1 then
            call IssueImmediateOrderBJ(aiHero, orderId)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction


    // Helper function to process point-target abilities (random or closest enemy in area)
    function ProcessAreaTargetEnemyAbility takes unit aiHero, real castRange, location heroLoc, string orderId, boolean isRandom returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsEnemyUnitAlive))
        local unit targetUnit
        local location targetPoint
        local boolean abilityUsed = false

        if isRandom then
            set targetUnit = GroupPickRandomUnitCustom(nearbyEnemies)
        else
            set targetUnit = GetClosestUnitInGroup(aiHero, nearbyEnemies)
        endif

        if targetUnit != null then
            set targetPoint = GetUnitLoc(targetUnit)
            call IssuePointOrderLocBJ(aiHero, orderId, targetPoint)
            call RemoveLocation(targetPoint)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction


    // Helper function to process point-target abilities (random or closest enemy in area) with debug support
    function ProcessPointTargetEnemyAbility takes unit aiHero, real castRange, location heroLoc, string orderId, boolean isRandom returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsEnemyUnitAlive))
        local unit targetUnit = null
        local location targetPoint
        local boolean abilityUsed = false

        if isDebuggingCustomAi then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Nearby enemies found: " + I2S(CountUnitsInGroup(nearbyEnemies)))
        endif

        if not isRandom then
            set targetUnit = GetClosestUnitInGroup(aiHero, nearbyEnemies)
            if isDebuggingCustomAi then
                if targetUnit != null then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Target unit: " + GetUnitName(targetUnit) + " (ID: " + I2S(GetHandleId(targetUnit)) + ") at (" + R2S(GetUnitX(targetUnit)) + ", " + R2S(GetUnitY(targetUnit)) + ")")
                else
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "No target unit found for point ability. (not random)")
                endif
            endif
        else
            set targetUnit = GroupPickRandomUnitCustom(nearbyEnemies)
            if isDebuggingCustomAi then
                if targetUnit != null then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Target unit: " + GetUnitName(targetUnit) + " (ID: " + I2S(GetHandleId(targetUnit)) + ") at (" + R2S(GetUnitX(targetUnit)) + ", " + R2S(GetUnitY(targetUnit)) + ")")
                else
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "No target unit found for point ability. (random)")
                endif
            endif
        endif

        if targetUnit != null then
            set targetPoint = GetUnitLoc(targetUnit)
            if isDebuggingCustomAi then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "castRange: " + R2S(castRange))
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "orderId for point ability: " + orderId)
            endif
            call IssuePointOrderLocBJ(aiHero, orderId, targetPoint)
            call RemoveLocation(targetPoint)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
    endfunction

    // Helper function to process unit-enemy target abilities (random or closest enemy in area)
    function ProcessUnitEnemyTargetAbility takes unit aiHero, real castRange, location heroLoc, string orderId, boolean isRandom returns boolean
        local group nearbyEnemies = GetUnitsInRangeOfLocMatching(castRange, heroLoc, Condition(function IsEnemyUnitAlive))
        local unit targetUnit
        local boolean abilityUsed = false

        if not isRandom then
            set targetUnit = GetClosestUnitInGroup(aiHero, nearbyEnemies)
        else
            set targetUnit = GroupPickRandomUnitCustom(nearbyEnemies)
        endif

        if targetUnit != null then
            call IssueTargetOrderBJ(aiHero, orderId, targetUnit)
            set abilityUsed = true
        endif

        call DestroyGroup(nearbyEnemies)
        return abilityUsed
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
        local location heroLoc
        local boolean abilityUsed = false
        local string orderId
        local integer result
        local timer t
        local integer currentOrder
        local boolean isRandom = false
        local integer mana
        local integer hp 
        local integer enemies 
        local boolean shouldSkip = false
        local real minDist 
        local real dist
        local group g 
        local unit u 
        local real x1 
        local real y1 
       
       
        if isDebuggingCustomAi then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "----------------------------- Initializing ---------------------------")
        endif
		
        // Cooldown check to avoid animation-lock and repeated orders
        if LoadBoolean(udg_customAiUnitTypesHash, GetHandleId(aiHero), 1) == true then
            // Cooldown active, skip casting
            if isDebuggingCustomAi then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unit is on cooldown for spell queue ")
            endif
            return false
        endif

        set currentOrder = GetUnitCurrentOrder(aiHero)
        if isDebuggingCustomAi then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "The current order is: " + I2S(currentOrder))
            // Debug: Show current orderId comparisons
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_NONE): " + I2S(OrderId(ORDER_ID_NONE)))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_STOP): " + I2S(OrderId(ORDER_ID_STOP)))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_MOVE): " + I2S(OrderId(ORDER_ID_MOVE)))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_ATTACK): " + I2S(OrderId(ORDER_ID_ATTACK)))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_PATROL): " + I2S(OrderId(ORDER_ID_PATROL)))
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Comparing currentOrder: " + I2S(currentOrder) + " with OrderId(ORDER_ID_SMART): " + I2S(OrderId(ORDER_ID_SMART)))
        endif
        // Check if hero is in a normal stance (not casting/channeling)
        if not(currentOrder == OrderId(ORDER_ID_NONE) or currentOrder == OrderId(ORDER_ID_STOP) or currentOrder == OrderId(ORDER_ID_MOVE) or currentOrder == OrderId(ORDER_ID_ATTACK) or currentOrder == OrderId(ORDER_ID_PATROL) or currentOrder == OrderId(ORDER_ID_SMART)) then
            // If not in a normal stance, likely casting/channeling, so return early
            if isDebuggingCustomAi then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unit is busy casting or channeling spell")
            endif
            return false
        endif

        // Set cooldown flag for this unit
        call SaveBoolean(udg_customAiUnitTypesHash, GetHandleId(aiHero), 1, true)

        // Start a timer to remove cooldown after 1 second
        set t = CreateTimer()
        // Save the aiHero handle id in the timer hash so ResetOrderCd can access it
        call SaveInteger(udg_customAiUnitTypesHash, GetHandleId(t), 0, GetHandleId(aiHero))
        call TimerStart(t, udg_customAiHeartbeat, false, function ResetOrderCd)

        if(udg_customAiUnitTypeControl) then
            // Check if the unit type is registered
            set result = LoadInteger(udg_customAiUnitTypesHash, GetUnitTypeId(aiHero), 0)
            if result == 0 then
                if isDebuggingCustomAi then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unit is not registered for spell queue.")
                endif
                return false
            endif
        endif



        // Loop through registered abilities
        loop
            exitwhen i >= udg_registeredAbilityCount
            set abilityId = udg_registeredAbilities[i]
            set udg_customAiHeroAbility = aiHero
            //call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Checking id: " + I2S(abilityId))
            // Check if the hero has the ability
            if GetUnitAbilityLevel(aiHero, abilityId) > 0  then
                set targetType = LoadInteger(udg_customAiAbilitiesHash, abilityId, 0)
                set castRange = LoadReal(udg_customAiAbilitiesHash, abilityId, 1)
                set orderId = LoadStringBJ(2, abilityId, udg_customAiAbilitiesHash)
                set isRandom = LoadBoolean(udg_customAiAbilitiesHash, abilityId, 3)
                set mana = LoadInteger(udg_customAiAbilitiesHash, abilityId, 4)
                set hp = LoadInteger(udg_customAiAbilitiesHash, abilityId, 5)
                set enemies = LoadInteger(udg_customAiAbilitiesHash, abilityId, 6)
                
                
                // Check if the hero has enough mana
                if isDebuggingCustomAi then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Step 1: Checking mana for abilityId: " + I2S(abilityId))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Current mana: " + R2S(GetUnitState(aiHero, UNIT_STATE_MANA)))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Max mana: " + R2S(GetUnitState(aiHero, UNIT_STATE_MAX_MANA)))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Mana threshold: " + I2S(mana))
                    if(GetUnitState(aiHero, UNIT_STATE_MAX_MANA) > 0) then
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Mana percent: " + R2S((GetUnitState(aiHero, UNIT_STATE_MANA) / (GetUnitState(aiHero, UNIT_STATE_MAX_MANA) * 1.00)) * 100))
                    else
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Max mana is zero, cannot calculate ratio.")
                    endif
                endif    
                if(GetUnitState(aiHero, UNIT_STATE_MAX_MANA) > 0 and((GetUnitState(aiHero, UNIT_STATE_MANA) / GetUnitState(aiHero, UNIT_STATE_MAX_MANA)) * 100) <= mana) then
                    // Not enough mana percentage, skip this ability
                    if isDebuggingCustomAi then
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Should skip this cast based on mana.")
                    endif
                    set shouldSkip = true
                else
                    // Enough mana, do not skip
                    set shouldSkip = false
                endif

                

                // Check if the hero has enough health
                if isDebuggingCustomAi then
                    // Debug output for HP calculation
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Current HP: " + R2S(GetUnitState(aiHero, UNIT_STATE_LIFE)))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Max HP: " + R2S(GetUnitState(aiHero, UNIT_STATE_MAX_LIFE)))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "HP Ratio: " + R2S(GetUnitState(aiHero, UNIT_STATE_LIFE) / GetUnitState(aiHero, UNIT_STATE_MAX_LIFE)))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Remaining HP %: " + R2S((GetUnitState(aiHero, UNIT_STATE_LIFE) / GetUnitState(aiHero, UNIT_STATE_MAX_LIFE)) * 100))
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "HP Threshold: " + I2S(hp))
                endif
                
                if((GetUnitState(aiHero, UNIT_STATE_LIFE) / GetUnitState(aiHero, UNIT_STATE_MAX_LIFE)) * 100) >(hp) then
                    // Not enough missing health percentage, skip this ability
                    if isDebuggingCustomAi then
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Should skip this cast based on hp.")
                    endif
                    set shouldSkip = true
                endif

                if not(shouldSkip) then
                    if isDebuggingCustomAi then
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Trying to cast spell.")
                    endif
                    set heroLoc = GetUnitLoc(aiHero)
                    if targetType == TARGET_TYPE_UNIT and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessUnitEnemyTargetAbility(aiHero, castRange, heroLoc, orderId, isRandom)
                    elseif targetType == TARGET_TYPE_POINT and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessPointTargetEnemyAbility(aiHero, castRange, heroLoc, orderId, isRandom)
                    elseif targetType == TARGET_TYPE_AREA and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessAreaTargetEnemyAbility(aiHero, castRange, heroLoc, orderId, isRandom)
                    elseif targetType == TARGET_TYPE_NO_TARGET and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessNoTargetEnemyNearbyAbility(aiHero, castRange, heroLoc, orderId)
                    elseif targetType == TARGET_TYPE_UNIT_ALLY and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessUnitAllyTargetAbility(aiHero, castRange, heroLoc, orderId, isRandom)
                    elseif targetType == TARGET_TYPE_SELF and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessSelfTargetDeadNearbyAbility(aiHero, castRange, heroLoc, orderId, enemies)
                    elseif targetType == TARGET_TYPE_NO_TARGET_DEAD_CHECK and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessNoTargetDeadEnemyAbility(aiHero, castRange, heroLoc, orderId, enemies)
                    elseif targetType == TARGET_TYPE_NO_TARGET_DEAD_CHECK_ALLY and not IsAbilityOnCooldown(aiHero, abilityId) then
                        set abilityUsed = ProcessNoTargetDeadAllyAbility(aiHero, castRange, heroLoc, orderId, enemies)
                    elseif not IsAbilityOnCooldown(aiHero, abilityId) then
                        if isDebuggingCustomAi then
                            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "ERROR: No valid target type found for ability with ID: " + I2S(abilityId))
                            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "This is probably an issue with the custom ability registration, please check your GUI code and make sure you are using the correct integer that represents target type for the ability.")
                        endif
                    endif
                    call RemoveLocation(heroLoc)
                endif
            endif

            set i = i + 1
        endloop

        return abilityUsed
    endfunction 
endlibrary


