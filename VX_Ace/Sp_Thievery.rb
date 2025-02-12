class Thievery
  #--------------------------------------------------------------------------
  # * Constants
  #-------------------------------------------------------------------------- 
  ## index is the class id. id 0 will be used for the default of invaild indexes
  PICK_LOCK_BASE =      [0,0,0,0,0,0,0  ,24 ,0,0]
  PICK_LOCK_FACTOR =    [7,7,7,7,7,7,7  ,1.4,7,7]
  
  DETECT_TRAP_BASE =    [0,0,0,0,0,0,24 ,24 ,0,0]
  DETECT_TRAP_FACTOR =  [7,7,7,7,7,7,1.4,1.4,7,7] 
  
  DISARM_TRAP_BASE =    [0,0,0,0,0,0,24 ,24 ,0,0]
  DISARM_TRAP_FACTOR =  [7,7,7,7,7,7,1.4,1.4,7,7] 
  
  #--------------------------------------------------------------------------
  # * Get a value scaled by the level
  #   NOTE: a base of 0 at a factor of 7 will return 15 at lvl 99
  #   factor of 2 is 50 at 99, and factor of 1 is 99
  #-------------------------------------------------------------------------- 
  def self.get_scaled_value(level, base, factor)
    return ((level-1).to_f/factor.to_f + 1) + base.to_f
  end
  
  #--------------------------------------------------------------------------
  # * Get the pick lock chance for the provided actor
  #-------------------------------------------------------------------------- 
  def self.get_pick_lock_chance(actor, bonus=0)
    return get_scaled_value(actor.level, 
    PICK_LOCK_BASE[actor.class_id] || PICK_LOCK_BASE[0], 
    PICK_LOCK_FACTOR[actor.class_id] || PICK_LOCK_FACTOR[0]
    ) + bonus
  end
  
  #--------------------------------------------------------------------------
  # * Get the detect trap chance for the provided actor
  #-------------------------------------------------------------------------- 
  def self.get_detect_trap_chance(actor, bonus=0)
    return get_scaled_value(actor.level, 
    DETECT_TRAP_BASE[actor.class_id] || DETECT_TRAP_BASE[0], 
    DETECT_TRAP_FACTOR[actor.class_id] || DETECT_TRAP_FACTOR[0]
    ) + bonus
  end
    
  #--------------------------------------------------------------------------
  # * Get the disarm trap chance for the provided actor
  #-------------------------------------------------------------------------- 
  def self.get_disarm_trap_chance(actor, bonus=0)
    return get_scaled_value(actor.level, 
    DISARM_TRAP_BASE[actor.class_id] || DISARM_TRAP_BASE[0], 
    DISARM_TRAP_FACTOR[actor.class_id] || DISARM_TRAP_FACTOR[0]
    ) + bonus
  end
  
  #--------------------------------------------------------------------------
  # * Roll check to pick lock
  #-------------------------------------------------------------------------- 
  def self.lock_picked?(actor, difficulty=0,bonus=0)
    roll = 1 + rand(100 + difficulty)
    print " roll: "; print roll; print " | "
    return get_pick_lock_chance(actor, bonus) >= roll
  end
  
  #--------------------------------------------------------------------------
  # * Roll check to detect trap
  #-------------------------------------------------------------------------- 
  def self.trap_detected?(actor, difficulty=0,bonus=0)
    roll = 1 + rand(100 + difficulty)
    print " roll: "; print roll; print " | "
    return get_detect_trap_chance(actor, bonus) >= roll
  end
  
  #--------------------------------------------------------------------------
  # * Roll check to disarm trap
  #-------------------------------------------------------------------------- 
  def self.trap_disarmed?(actor, difficulty=0,bonus=0)
    roll = 1 + rand(100 + difficulty)
    print " roll: "; print roll; print " | "
    return get_disarm_trap_chance(actor, bonus) >= roll
  end
  
end
