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

  -rules with injections and overrides may be fliped for files that are compressed into one only for editing reasons
  and only if they can work that way.

  -files in their own directory beside rpg maker versions will try to handle aliasing better.
  loose files append with old due to Ext and Inj files being merged. This will cause a stack too deep issue
  if two files use the same old alias id. The new system still prefix with old, but appends with the namespace
  of the project that aliasing. This may result in long methood name, so namespace id may be reduce if nessary.


Install:
Each project should be independent. I will try to comment at the top of the file any dependencies.
Load Order:
  -The scripts should be added under `▼ Materials` and should be added before any file with _Injections or _Inj
  -Injections should be added last
  -Extentsions should be added before anything that depends on the features they add to the base class,
    else they can be place where ever, but since they may override with getters or setters, then
    they should be read and add the logic to any existing files that changes base classes or modified
    to work with others scripts. Also in this case, the one who override is desired, should be added last.
    
  -Compress scripts (ones with `# * INJECTION * ` comments) may be able to be place anywhere as long as it is before Configs, 
    but might be best after extensions since ext may override some functionalites. Major issue with order is menu placement 
    order if it adds a menu.

  -`Config` scripts are added last. Their role is to write over the defaults without having to change the file
    directly. 
    ```class Script_Name
        CONSTANT_OF_THE_SAME_NAME = new_value
    end```
    is a simple, but poor, example. Since some scripts will need to work with others database, overriding
    the constants in a diffrent file will help incase the file is updated. 
    
      This is an example window that display a window at the top of the screen for 120 frames. It will stack notifcations in a hash where the key is the message and
      value is the amount of times it was called. This will keep the window up as long as there are messages in the queue hash, but also allow the queue to compress 
      same messages by apending x# (where # is the value) when value is greater than 1.
      
