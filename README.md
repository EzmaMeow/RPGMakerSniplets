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


Install:
Each project should be independent. I will try to comment at the top of the file any dependencies.
Load Order:
  -The scripts should be added under `▼ Materials` and should be added before any file with _Injections or _Inj
  -Injections should be added last
  -Extentsions should be added before anything that depends on the features they add to the base class,
    else they can be place where ever, but since they may override with getters or setters, then
    they should be read and add the logic to any existing files that changes base classes or modified
    to work with others scripts. Also in this case, the one who override is desired, should be added last.

  -`Config` scripts are added last. Their role is to write over the defaults without having to change the file
    directly. 
    ```class Script_Name
        CONSTANT_OF_THE_SAME_NAME = new_value
    end```
    is a simple, but poor, example. Since some scripts will need to work with others database, overriding
    the constants in a diffrent file will help incase the file is updated. 
    
    
Project List:
-Magic_Blood:
  A mechanic that allow hp to cast spells. This is usally base on 10 time the mp cost and will replace
  the mp cost with the hp cost.

-Sp_WeaponClasses:
  This allow a character class to change when equiping weapons. The wepon type id points to a class id.

-Game_Enemy_Extension:
  This current just give a level var to enemies, fixing the issue of using level in the damage formula feild
  As well as opening up other possibilities. Currently also adds:
    -stats that scale on level. the enemy stats in data base will be treated as level 1 stats.
      This also applies to exp and gold.

-Calculations_Formulas:
  A class that provide functions to use with damage formula. It ment to be modify so that the namespace
  of Formula will be used for fetching the function. The first common parameters will be `base_damage, attack, defence` 
  as int or floats. There may be deviations as well as ones using the `base_damage, a, b, v` parameters for more advance caculations.

-SP_Thievery:
  This is to provide functionality for lockpick, detect traps, disarm traps, and other realated skills.
  Currently it provide each class with a base and factor for each of the three skills and functions for getting this 
  value for the used of roll checks.

-Modual: 
  -Story:
    This is more of an example. It contains a way to trigger events by script call instead of depending on parallel processes.
    It also meant to provide session base varibles and tools to help regulate the story progression, but that will be unque to the game
    so it is unlikly I will add that here.
      -a use example: lets say I have a lot of events representing road blockers. Instead of setting them all to parallel processes to check
      the game state, they are instead added to the story state notify system and only run their checks when the state is changed or Story.notify get called.
      -It also allow a way to get a stated by a string instead of an id if set up that way. This allows prototypes to switch game varibles around without having to 
      edit all the events that depends on that varible. I guess once can add a version checker and do such thing for non prototpes without breaking saves
      -in short, this modual is meant to help manage story progressions that might be too crazy to handle with just event limitations.

  -Windows:
    windows usally need to be injected into the existing scene or hanlde directly. If I provide a way to inject it out of the box, I will comment the file at the top 
    -Window_Notify:
      This is an example window that display a window at the top of the screen for 120 frames. It will stack notifcations in a hash where the key is the message and
      value is the amount of times it was called. This will keep the window up as long as there are messages in the queue hash, but also allow the queue to compress 
      same messages by apending x# (where # is the value) when value is greater than 1.
      
