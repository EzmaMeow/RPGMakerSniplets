
#this should allow the use of shields in the offhand when a class have the duel wield flag.
#It uses weapon types to figure out two handed weapons, bit the is_two_handed function
#can be overriden to add additonal ways. Note: Will not be able to hold two handed weapons
#in the offhand slot

class Game_Actor
  
  TWO_HANDED_WEAPON_TYPES = [5,6,9,10]
  
  def is_two_handed?(wtype_id)
    TWO_HANDED_WEAPON_TYPES.include?(wtype_id)
  end
  
  def can_equip_in_slot(slot_id,item)
    #if in offhand slot
    if slot_id == 1
      main_weapon = @equips[0].object
      if main_weapon
        if is_two_handed?(main_weapon.wtype_id)
          return false
        end
      end
      #if a weapon
      if item.etype_id == 0
        return false if is_two_handed?(item.wtype_id)
        return false if !dual_wield?
      #if a shield
      elsif item.etype_id == 1
        return false if equip_type_sealed?(1)
      end
    #else
    #  return false if equip_slots[slot_id] != item.etype_id
    end
    return false if equip_slots[slot_id] != item.etype_id
    return true
  end
  
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if (item && !can_equip_in_slot(slot_id,item))
    @equips[slot_id].object = item
    refresh
  end
    def release_unequippable_items(item_gain = true)
    loop do
      last_equips = equips.dup
      @equips.each_with_index do |item, i|
        if !equippable?(item.object) || !can_equip_in_slot(i,item.object)
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
      end
      return if equips == last_equips
    end
  end
  
  
  def equippable?(item, slot = nil)
    unless slot.nil?
      if slot == 1 and dual_wield?
        return (super(item) and not equip_type_sealed?(1))
      end
    end
    return super(item)
  end
  
end


class Window_EquipItem < Window_ItemList
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if !@actor.can_equip_in_slot(@slot_id,item)
    return @actor.equippable?(item)
  end
end
