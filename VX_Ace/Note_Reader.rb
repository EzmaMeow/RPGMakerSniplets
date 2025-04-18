
# * INJECTIONS  * 

##Exposing notes in the Game_Map
class Game_Map
  def note
    return "" if !@map
    return @map.note
  end
end
##Exposing notes in ItemBase which expose it for items, skills, and armor/weapons
class Scene_ItemBase < Scene_MenuBase
  def note
    return "" if !@class
    return @class.note
  end
end

#to acessenemy notes: #$game_troop.members[0].enemy.note
#to acessparty member notes: #$game_party.members[0].actor.note
#to acess class notes: #$game_party.members[0].class.note


#--------------------------------------------------------------------------
# * RPG::BaseItem
#--------------------------------------------------------------------------
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Get Tags Array 
  #   A way to tag item base objects. Can be used as filtering for advance sorting
  #--------------------------------------------------------------------------
  def tags
    if @tags == nil
      @tags = Note_Reader.get_tags(self)
    end
    return @tags
  end
  #--------------------------------------------------------------------------
  # * Get priority
  #   priority acts as a diffrent group so skill
  #   id order is perserve within the same priority
  #--------------------------------------------------------------------------
  def priority
    if @priority == nil
      @priority = Note_Reader.get_variable("priority",self,15).to_i
    end
    return @priority
  end
end

#--------------------------------------------------------------------------
# * Game_Actor
#--------------------------------------------------------------------------
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Get Skills Array 
  #--------------------------------------------------------------------------
  def skills
    default = (@skills | added_skills).collect {|id| $data_skills[id] }
    return default.sort_by { |skill| (skill.priority*1000 + skill.id) }
  end
end

#--------------------------------------------------------------------------
# * Game_Party 
#--------------------------------------------------------------------------
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Get Item Object Array 
  #--------------------------------------------------------------------------
  def items
    default = @items.keys.sort.collect {|id| $data_items[id] }
    return default.sort_by { |item| (item.priority*1000 + item.id) }
  end
  #--------------------------------------------------------------------------
  # * Get Weapon Object Array 
  #--------------------------------------------------------------------------
  def weapons
    default = @weapons.keys.sort.collect {|id| $data_weapons[id] }
    return default.sort_by { |item| (item.priority*1000 + item.id) }
  end
  #--------------------------------------------------------------------------
  # * Get Armor Object Array 
  #--------------------------------------------------------------------------
  def armors
    default = @armors.keys.sort.collect {|id| $data_armors[id] }
    return default.sort_by { |item| (item.priority*1000 + item.id) }
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
class Game_Interpreter
  
  #check for items with a tag. This could check all items, so it should not
  #check every update
  def has_items_with_tag?(tag, amount=1, of_any=true, check_equip = false, source=$game_party.all_items)
    count = 0
    for item in source
      next unless item
      next unless item.tags.include?(tag) 
      count += $game_party.item_number(item)
      if check_equip
        #this current wont count them all. 
        #and is here only so weapon and armor checks
        #count check may get added later
        count += 1 if $game_party.members_equip_include?(item)
      end
      if count >= amount
        return true
      end
      if !of_any
        count = 0
      end
    end
    return false
  end
  def has_weapon_with_tag?(tag, check_equip = true)
    has_items_with_tag?(tag, 1,true,check_equip,$data_weapons)
  end
  def has_armor_with_tag?(tag, check_equip = true)
    has_items_with_tag?(tag, 1,true,check_equip,$data_armors)
  end
  
end


# * Base  * 

module Note_Reader
  TAG_IDENTIFIER = '@'

  def self.get_variables(source)
    vars = {}
    if source.respond_to?(:note)
      for scan_results in source.note.scan(/@(.*?)=(.*?);/)
        if scan_results.size >= 2
          vars[scan_results[0]] =scan_results[1]
        end
      end
    end
    return vars
  end
  
  def self.get_variable(key,source,default = 0)
    if key == nil; return default; end 
    if source.respond_to?(:note)
      results = source.note.match(/@#{key}=(.*?);/)
      if results != nil
        return results[1]
      end
    end
    return default
  end
  
  def self.get_tags(source)
    if source.respond_to?(:note)
      return source.note.scan(/#(\w+)/).flatten
    end
    return []
  end
  
end
