#Requires Sp_WeaponClasses
#--------------------------------------------------------------------------
# * Game_Actor
#--------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  alias old_change_equip change_equip
  alias old_change_equip_by_id change_equip_by_id
  
  #--------------------------------------------------------------------------
  # * Change Equipment
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    old_change_equip(slot_id, item)

    if item.class == RPG::Weapon
      Sp_WeaponClasses.on_weapon_change(item,self)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (Specify with ID)
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    old_change_equip_by_id
    if equip_slots[slot_id] == 0
      Sp_WeaponClasses.on_weapon_change($data_weapons[item_id],self)
      #TODO: test this or disable this. not sure when this is used
    end
  end
end
