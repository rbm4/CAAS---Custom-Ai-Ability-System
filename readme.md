------------
Caas - Custom Ai ability system
------------
************************************************************************************

   ------------
   Description:
   ------------
   A lightweight system that aims to control conditionals for units in general to use a myriad of custom abilities from any
   different types of abilities in the warcraft 3 engine. It is well known that the base warcraft 3 AI system does not control every ability correctly
   this system aims to be a backbone for the usage of any ability in-game for many supported conditionals present here.
   Initially designed for AI heroes in my custom map, but can be used for any unit.
   By Ricardo Malafaia (darkprofeta).
   This library is also a final course work for my Information Systems degree, the system was made inside my custom map
   and improved in many ways to be more flexible and useful for any type of map and used as submission for the course. 

   -------------------
   Usage instruction:
   -------------------
   The system will need for you to inform the ability ID, target type, cast range and order ID for each custom 
   ability you want to register, do not use the same orderId for a given unit and avoid changing the original orderId
   of the abilities you want to register.
   A good way to test the system is for you to have an player-controlled unit to have it cast an ability on the 
   onDamage event, if an ability is not being cast you may want to double-check if you informed the correct target type
   or conditionals for the ability. 
   Take your time and test one ability at a time.

   ---------
   Features:
   ---------
   - Allows you register an unit-type, ability ID, target type, range and order ID for a custom ability to be controlled
   - Many GUI friendly triggers that represent each type of usage for the custom abilities
   - Allows to control conditionals like how much healthpoints or mana to decide whether to use abilities or not
   - Allows to control how many enemies are nearby to decide whether to use abilities or not
   - Allows to control if ability will be cast in a random target or the current target
   - onAttack, onAttacked, onAcquireRange, onPeriod are some of the supported events

   ----
   API:
   ----
  **function RegisterCustomAbility(integer unitTypeId, integer abilityId, integer targetType, real castRange, string orderId, integer minHp, integer minMana, integer minEnemies, boolean randomTarget)**
    - Registers a custom ability for a specific unit type with detailed conditionals such as minimum HP, mana, number of enemies, and whether to use a random target. Should be called during map initialization for each ability/unit combination.

  **function CastCustomAbilities(unit whichUnit) -> boolean**
    - Attempts to cast any registered custom abilities for the given unit, based on the defined conditionals and current game state. Returns true if an ability was cast.

  **function IsAbilityOnCooldown(unit whichUnit, integer abilityId) -> boolean**
    - Checks if the specified ability is currently on cooldown for the given unit.

  **function IsEnemyUnitAlive(unit whichUnit, unit targetUnit) -> boolean**
    - Determines if the target unit is alive and considered an enemy of the given unit.

  **function RegisterUnitType(integer unitTypeId) -> boolean**
    - Registers a unit type to be managed by the system, enabling it to use custom abilities as defined.

  **function SetAbilityConditionals(integer unitTypeId, integer abilityId, integer minHp, integer minMana, integer minEnemies, boolean randomTarget)**
    - Updates the conditionals for a registered ability, allowing dynamic adjustment of when and how abilities are used.

  **function SetAbilityCastRange(integer unitTypeId, integer abilityId, real castRange)**
    - Sets or updates the cast range for a registered ability for a specific unit type.

  **function SetAbilityOrderId(integer unitTypeId, integer abilityId, string orderId)**
    - Sets or updates the order ID used to cast the registered ability for a specific unit type.

  **function UnregisterCustomAbility(integer unitTypeId, integer abilityId)**
    - Removes a previously registered custom ability from the system for a specific unit type.

  **function UnregisterUnitType(integer unitTypeId)**
    - Removes a unit type and all its associated abilities from the system.


   --------------
   */ requires /*
   --------------
   CustomAiAbilitySystem has no requirements whatsoever.


   -------------------
   Import instruction:
   -------------------
   Simply copy and paste the Custom Ai Ability System folder into your map.
   I personally recommend you to take a look at the examples folder to see how to use the system properly

