
class Game_Enemy < Game_Battler
  
  alias old_initialize initialize
  
  attr_reader   :level                    # level
  attr_accessor :exp_scale_factor
  attr_accessor :gold_scale_factor 

  #--------------------------------------------------------------------------
  # * Setup 
  #   Added level to enemies to prevent level breaking damage fomulas
  #   (also to allow enemies to simulate having levels)
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    @level = 1
    @param_leveled = Array.new(8, 0)
    @param_scale_factor = Array.new(8, 10.0)
    @exp_scale_factor = 1.0
    @gold_scale_factor = 1.0
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
  # * Get Scale Value
  #   This  will scale a value by the provide factor and current level
  #--------------------------------------------------------------------------
  def get_scale_value(scale_factor = 1.0,base_value=1,min_value=1.0)
    return [((level-1)/scale_factor + 1)*base_value,min_value].max
  end
  
  #--------------------------------------------------------------------------
  # * Update param_leveled
  #   This will scale the enemy stats base on their level at the time of this
  #   being called
  #--------------------------------------------------------------------------
  def update_param_leveled(recover = true)
    for id in 0..7 do
      @param_leveled[id] = get_scale_value(param_scale_factor(id),enemy.params[id])
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
  
  #--------------------------------------------------------------------------
  # * (Overrding) Get Experience
  #--------------------------------------------------------------------------
  def exp
    return get_scale_value(exp_scale_factor,enemy.exp,0).floor 
  end
  #--------------------------------------------------------------------------
  # * (Overrding) Get Gold
  #--------------------------------------------------------------------------
  def gold
    return get_scale_value(gold_scale_factor,enemy.gold,0).floor 
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
