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
   function RegisterCustomAbility(integer abilityId, integer targetType, real castRange, string orderId)
     - Register a custom ability with the system, must be called on the initialization of the map ideally to register
    every use case of the custom abilities, many examples are shown on the examples folder.

   function CastCustomAbilities(unit aiHero) -> Returns a boolean value
     - Function that will cast the custom abilities registered for the aiHero unit 
    (doesn't actually requires the unit to be an hero, can be any unit)

   function IsAbilityOnCooldown(unit whichUnit) -> Returns a boolean value
     - Check if the a given ability is on cooldown for a unit

   function IsEnemyUnitAlive() -> Returns a boolean value
     - Check if the unit is an enemy and alive

   function RegisterUnitType(unit whichUnit) -> Returns a boolean value
     - Register a unit type to be used with the system


   --------------
   */ requires /*
   --------------
   CustomAiAbilitySystem has no requirements whatsoever.


   -------------------
   Import instruction:
   -------------------
   Simply copy and paste the Custom Ai Ability System folder into your map.
   I personally recommend you to take a look at the examples folder to see how to use the system properly

