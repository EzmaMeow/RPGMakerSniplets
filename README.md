# RPGMakerSniplets

Note: Most of this will be backup and references as I mess with RPG Maker.

## Load Order:
  I try not to depend too heavily on load order. Usally what is importatint is when functinality get alias or overriden
  so usally the order follows below:
  
  - Base classes Override or Overhaul
    
  - Base classes Extensions
    
  - Other classes
    
  - Other classes Override or Overhaul
    
  - Other classes Extensions
    
  - Injections
    
  - Configs
    
  Some scripts are features containing other classes, Extensions, or Injections in a single file. They should be treated as other classes or get added
  somewhere between that and configs as long as they do not have Overhaul in their name (else they should load first).
  Sadly I can not say where since it depends on what the other scipts do and it might not matter in most cases.

## Terms I may use:

  - Injection (Inj):
  
    These usally alias base classes functinality so the added script will be used as needed without depending on event calls
    
  - Extension (Ext):
  
    There are more focus on change an existing class and adding functionality to it. These are usally one of the first
    scripts to load in after any Override or Overhauls.
    
  - Override or Overhaul:
  
    These changes the base functionality in an unsafe way. They are meant to load first and usally
    made to allow fucture script to change functionality that the base code made too limited.
  - Configs:
  
    These scripts are usally not provided. They change constants or add to data structures of moduals
    depending on what the the user needs.
    
  - Features:
  
    These are usally more plug and play scripts that may modify a few base scripts to allow them to work.
    I will try to add keywords in comments like `#  *  INJECTIONS ` to help identify the type of changes.
    Also I will try to comment notes about load order, dependencies and general notes at the top of the file.

## NOTE:

  I will try to batch loose scripts into features overtime if I feel it will work together. I may reserver a dir for loose files I have no plan on 
  grouping up into features. Feature should be functional when the base script is added. Other files may be optional feature that may or may not depend
  on another feature. I will try to comment important notes at the top of the file for such cases.




      
