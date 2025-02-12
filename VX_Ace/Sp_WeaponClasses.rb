class Sp_WeaponClasses
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  ##index:weapon_type_id, value:class_id
  WEAPON_CLASSES = [nil,1,2,3,4,5,6,7,9,10] 
  KEEP_EXP = false  #enable or disable shared exp between classes
  #--------------------------------------------------------------------------
  # * Switch Class On Weapon Change
  #--------------------------------------------------------------------------
  def self.on_weapon_change(weapon,actor)
    if weapon.wtype_id > 0 && weapon.wtype_id < WEAPON_CLASSES.length
      class_id = WEAPON_CLASSES[weapon.wtype_id]
      if class_id && class_id != actor.class_id
        actor.change_class(class_id, KEEP_EXP)
        actor.init_skills
        #NOTE: if KEEP_EXP = false, classes seem to have their own exp stored
      end
    end
  end
end
