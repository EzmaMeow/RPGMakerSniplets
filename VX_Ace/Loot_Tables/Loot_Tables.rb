#this is an example of extending the loot list. Lists can act as rarity item list
#and these lists and item results can be reused once declared.
#currently changing the loot table enemies pull from beside the default
#would require injection via note reader or custom injection

#--------------------------------------------------------------------------
# *Loot_Item
#  ext of base item to hold data for a item in a loot table list
#--------------------------------------------------------------------------
class Loot_Item < Game_BaseItem
  attr_accessor :chance
  attr_accessor :min_amount
  attr_accessor :max_amount
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(item_class=nil, id=0, min_amt=1, max_amt=1,pick_chance=50)
    @class = item_class
    @item_id = id
    @min_amount = min_amt
    @max_amount = max_amt
    @chance = pick_chance
  end
  
  def amount
    return rand(@max_amount-@min_amount).floor + @min_amount
  end
end

#--------------------------------------------------------------------------
# *Loot_List
#--------------------------------------------------------------------------
class Loot_List
  attr_accessor :items
  attr_accessor :chance
  def initialize(item_list=[],pick_chance=50)
    @items = item_list
    @chance = pick_chance
  end
  
  def pick_item
    for item in @items
      next if !item
      sucess = item.chance
      roll = rand(100)
      if roll <= sucess
        return item
      end
    end
    return nil
  end
end

#--------------------------------------------------------------------------
# *Loot_Table
#--------------------------------------------------------------------------
class Loot_Table
  attr_accessor :lists
  def initialize(table_list = [])
    @lists = table_list
  end
  
  def pick_list
    for list in @lists
      next if !list
      sucess = list.chance
      roll = rand(100)
      if roll <= sucess
        return list
      end
    end
    return nil
  end
end

#--------------------------------------------------------------------------
# * Loot_Tables
#--------------------------------------------------------------------------
module Loot_Tables
  #this could be change to an array or split up
  #it mostly to declare resuable loot item object
  #also could add this data to item note
  #and make a func that grab it from an provided
  #item class and id.
  @items = {
    :item1=>Loot_Item.new(RPG::Item,1,1,1,65),
    :item2=>Loot_Item.new(RPG::Item,2,1,1,25),
    :item3=>Loot_Item.new(RPG::Item,3,1,1,10),
    :item4=>Loot_Item.new(RPG::Item,4,1,1,25),
    :item5=>Loot_Item.new(RPG::Item,5,1,1,10),
    :item6=>Loot_Item.new(RPG::Item,6,1,1,35),
    :item7=>Loot_Item.new(RPG::Item,7,1,1,10),
    :item8=>Loot_Item.new(RPG::Item,8,1,1,1)
  }
  
  @lists = {:potions=>
    Loot_List.new([
      @items[:item1],@items[:item6],@items[:item2],@items[:item4],
      @items[:item3],@items[:item5],@items[:item7],@items[:item8]
    ],50)
  }
  
  @tables = {
    :default => Loot_Table.new([@lists[:potions]])
  }

  def self.loot(key)
    table = @tables[key]
    return nil if !table
    list = table.pick_list
    return nil if !list
    return list.pick_item
  end
end

#--------------------------------------------------------------------------
# * RPG::Enemy
#--------------------------------------------------------------------------
class RPG::Enemy < RPG::BaseItem
  def drop_loot_id
    return :default
  end
end

#--------------------------------------------------------------------------
# * BattleManager
#--------------------------------------------------------------------------
module BattleManager
  class<<self
    alias :old_gain_drop_items_loot_tables :gain_drop_items
  end
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    loot_items = {}
    for enemy in $game_troop.dead_members
      next if !enemy.enemy.drop_loot_id
      next if enemy.drop_item_rate == 0
      #will roll more than once of droprate greater than 1
      for drop_roll in 1..enemy.drop_item_rate 
        loot = Loot_Tables.loot(enemy.enemy.drop_loot_id)
        next if !loot
        next if !loot.object
        if loot_items[loot.object]
          loot_items[loot.object] += loot.amount
        else
          loot_items[loot.object] = loot.amount
        end
      end
    end
    for loot in loot_items.keys
      amount = loot_items[loot]
      text = loot.name + " x" + amount.to_s
      $game_party.gain_item(loot, amount)
      $game_message.add(sprintf(Vocab::ObtainItem, text))
    end
    old_gain_drop_items_loot_tables
  end
end
