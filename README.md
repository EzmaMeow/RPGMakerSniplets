# RPGMakerSniplets

Note: Most of this will be backup and references as I mess with RPG Maker.

Terms:
  -Injection (Inj):
    This file mostly focus on adding to an existing methoods usally connecting a system to the file
    without ending with _Injection. (also means it depends on that file)
  -Extension (Ext):
    This file is mostly to add to an existing class or modual. It like the injection, but more focus
    on a single class and not dependent on other beside the one it is overriding. 

NOTE:
  -Currently the configuration of most scripts are stored as constants (All cap varibles) and may need to
  be modify to work with other projects. This may change in the future when ever I feel like testing other ways.

Project List:
-Magic_Blood:
  A mechanic that allow hp to cast spells. This is usally base on 10 time the mp cost and will replace
  the mp cost with the hp cost.

-Sp_WeaponClasses:
  This allow a character class to change when equiping weapons. The wepon type id points to a class id.

-Game_Enemy_Extension:
  This current just give a level var to enemies, fixing the issue of using level in the damage formula feild
  As well as opening up other possibilities.

-Calculations_Formulas:
  A class that provide functions to use with damage formula. It ment to be modify so that the namespace
  of Formula will be used for fetching the function. The first common parameters will be `base_damage, attack, defence` 
  as int or floats. There may be deviations as well as ones using the `base_damage, a, b, v` parameters for more advance caculations.
