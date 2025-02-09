class Game_Enemy < Game_Battler
  
  alias old_initialize initialize
  
  attr_reader   :level                    # level

  #--------------------------------------------------------------------------
  # * Setup 
  #   Added level to enemies to prevent level breaking damage fomulas
  #   (also to allow enemies to simulate having levels)
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    @level = 1
    @param_leveled = Array.new(8, 0)
    @param_scale_factor = Array.new(8, 10.0)  
    old_initialize(index, enemy_id)
    update_param_leveled(true)
  end
  
  #--------------------------------------------------------------------------
  # * Get param_leveled
  #--------------------------------------------------------------------------
  def param_leveled(param_id)
    @param_leveled[param_id]
  end
  
  #--------------------------------------------------------------------------
  # * Get param_scale_factor
  #--------------------------------------------------------------------------
  def param_scale_factor(param_id)
    @param_scale_factor[param_id]
  end
  
  #--------------------------------------------------------------------------
  # * Set param_scale_factor
  #   This value will be used to effect the stats leveling curve
  #--------------------------------------------------------------------------
  def set_param_scale_factor(param_id,value)
    @param_scale_factor[param_id] = value.to_f
  end
  
  
  #--------------------------------------------------------------------------
  # * Update param_leveled
  #   This will scale the enemy stats base on their level at the time of this
  #   being called
  #--------------------------------------------------------------------------
  def update_param_leveled(recover = true)
    for id in 0..7 do
      level_modifier = 1
      scale_factor =  param_scale_factor(id)
      if @level >= 1
        level_modifier = (level-1)/param_scale_factor(id) + 1
        #level_modifier = (@level-1+scale_factor)/scale_factor
      end
      @param_leveled[id] = (enemy.params[id] * level_modifier).floor
    end
    if recover
      recover_all
    end
  end
  

  
  #--------------------------------------------------------------------------
  # * Set Level
  #   For event scripts to call to set an enemy level
  #   Should only be used for enemies that stats are design to scale with level
  #--------------------------------------------------------------------------
  def set_level(new_level, max_level = 99, recover = true)
    @level = [[new_level, max_level].min, 1].max
    update_param_leveled(recover)
  end
  
  #--------------------------------------------------------------------------
  # * (Overrding) Get Base Value of Parameter
  #--------------------------------------------------------------------------
  def param_base(param_id)
    param_leveled(param_id)
  end
  
  #NOTE: Help has this infomation, but keeping it here to
  #help with testing for now:
  #0: Maximum hit points 
  #1: Maximum magic points 
  #2: Attack power 
  #3: Defense power 
  #4: Magic attack power 
  #5: Magic defense power 
  #6: Agility 
  #7: Luck 

end
