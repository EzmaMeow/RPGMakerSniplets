
# * CLASSES  *

#--------------------------------------------------------------------------
# * Recipe_Element
#   The base object for an ingredient or result slot
#--------------------------------------------------------------------------
class Recipe_Element
  def initialize
  end
  
  def amount(total=1,index=0)
    0
  end
  
  def amount_owned(index=0)
    0
  end
  
  def name(index=0)
    "Empty Element"
  end
  
  def icon(index=0)
    0
  end
  
  def use?(total=1,index=0)
    return false
  end
  
  def use(total=1,index=0)
  end
  
  def create?(total=1,index=0)
    return false
  end
  
  def create(total=1,index=0)
  end
end

#--------------------------------------------------------------------------
# * Recipe_Item 
#   An Recipe_Element representing an item
#--------------------------------------------------------------------------
class Recipe_Item < Recipe_Element
  def initialize(item_type, item_id,amount)
    @item_type = item_type
    @item_id = item_id
    @amount = amount
  end
  
  def item_source
    return $data_items   if @item_type == RPG::Item
    return $data_weapons if @item_type == RPG::Weapon
    return $data_armors  if @item_type == RPG::Armor
    return [] 
  end
  
  def amount(total=1)
    @amount * total
  end
  
  def amount_owned
    item = item_source[@item_id]
    return 0 if !item
    return $game_party.item_number(item)
  end
  
  def name
    item = item_source[@item_id]
    return "nil" if !item
    return item.name
  end
  
  def icon
    item = item_source[@item_id]
    return 0 if !item
    return item.icon_index
  end
  
  #for ingredients
  def use?(total=1)
    item = item_source[@item_id]
    return false if !item
    return false if amount_owned < amount(total)
    return true
  end
  
  def use(total=1)
    item = item_source[@item_id]
    return if !item
    $game_party.gain_item(item, -amount(total))
  end
  
  #for results
  def create?(total=1)
    item = item_source[@item_id]
    return false if !item
    max = $game_party.max_item_number(item)
    future_amount = amount_owned + amount(total)
    return false if future_amount > max
    return true
  end
  
  def create(total=1)
    item = item_source[@item_id]
    return if !item
    $game_party.gain_item(item, amount(total))
  end
end
#--------------------------------------------------------------------------
# * Base_Recipe 
#   An object for recipe infomation
#--------------------------------------------------------------------------
class Base_Recipe
  attr_accessor :name
  
  def initialize(name="recipe", ingredients = [] ,results = [])
    @name = name
    @ingredients = ingredients
    @results = results
  end

  #ingredient getters
  def ingredients
    @ingredients
  end
  def ingredient(index)
    @ingredients[index]
  end
  
  #results getters
  def results
    @results
  end
  def result(index)
    @results[index]
  end
  
end

#CORE
#--------------------------------------------------------------------------
# * Recipe_Handler 
#   Stores registered recipe lists
#--------------------------------------------------------------------------
module Recipe_Handler
  @common_recipes = [
    Base_Recipe.new("Scrap Axe",[Recipe_Item.new(RPG::Item,17,1),
    Recipe_Item.new(RPG::Item,19,2), Recipe_Item.new(RPG::Item,20,1)],
    [Recipe_Item.new(RPG::Weapon,61,1)]),
    Base_Recipe.new("Scrap Spear",[Recipe_Item.new(RPG::Item,17,1),
    Recipe_Item.new(RPG::Item,19,1), Recipe_Item.new(RPG::Item,20,1)],
    [Recipe_Item.new(RPG::Weapon,62,1)]),
    Base_Recipe.new("Scrap Sword",[Recipe_Item.new(RPG::Item,20,1),
    Recipe_Item.new(RPG::Item,19,2)],
    [Recipe_Item.new(RPG::Weapon,63,1)]),
    Base_Recipe.new("Scrap Knife",[Recipe_Item.new(RPG::Item,20,1),
    Recipe_Item.new(RPG::Item,19,1)],
    [Recipe_Item.new(RPG::Weapon,64,1)]),
    Base_Recipe.new("Wooden Club",[Recipe_Item.new(RPG::Item,17,1),
    Recipe_Item.new(RPG::Item,20,1)],
    [Recipe_Item.new(RPG::Weapon,65,1)]),
    Base_Recipe.new("Wooden Staff",[Recipe_Item.new(RPG::Item,17,1)],
    [Recipe_Item.new(RPG::Weapon,66,1)])
  ]
  
  #should hold recipe object and fuctions for working with it
  def self.common_recipes
    @common_recipes
  end
   
end
