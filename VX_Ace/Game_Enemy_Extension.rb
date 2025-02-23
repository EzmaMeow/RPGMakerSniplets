
class Game_Enemy < Game_Battler
  
  alias old_transform transform
  
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  PARAM_SCALED_FACTOR = Array.new(8, 10.0)
  EXP_SCALED_FACTOR = 1.0
  GOLD_SCALED_FACTOR = 1.0
  PARAM_VARIANCE_FACTOR = 10.0
  MAX_LEVEL = 99
  USE_PARTY_AVERAGE_LEVEL = false
  
  alias old_initialize initialize
  
  attr_reader   :level
  
  def party_average_level(use_average = false,level=1)
    if use_average
      level_sum = 0
      for actor in $game_party.members
        level_sum += actor.level
      end
      return (level_sum.to_f / $game_party.members.size.to_f).to_i
    end
    return level
  end
  
  def default_level
    value = party_average_level(USE_PARTY_AVERAGE_LEVEL)
    if $game_map.respond_to?(:default_level)
      value = $game_map.default_level(value)
    end
    if $game_troop.respond_to?(:default_level)
      value = $game_troop.default_level(value)
    end
    return value
  end
  
  def exp_scale_factor
    return EXP_SCALED_FACTOR
  end
  
  def gold_scale_factor
    return GOLD_SCALED_FACTOR
  end

  def init_params_factors(index, enemy_id)
    @param_variance_factor = Array.new(8, PARAM_VARIANCE_FACTOR)
    @param_scale_factor = PARAM_SCALED_FACTOR.clone
  end
  
  #--------------------------------------------------------------------------
  # * Setup 
  #   Added level to enemies to prevent level breaking damage fomulas
  #   (also to allow enemies to simulate having levels)
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    @param_leveled = Array.new(8, 0)
    @param_variance = Array.new(8, 0)
    init_params_factors(index, enemy_id)
    old_initialize(index, enemy_id)
    @level = default_level
    refresh_params(true,true)
  end
  
  #--------------------------------------------------------------------------
  # * Get param_leveled
  #--------------------------------------------------------------------------
  def param_leveled(param_id)
    @param_leveled[param_id]
  end
  
  #--------------------------------------------------------------------------
  # * Get param_variance_factor
  #--------------------------------------------------------------------------
  def param_variance_factor(param_id)
    @param_variance_factor[param_id]
  end
  
  #--------------------------------------------------------------------------
  # * Get param_variance
  #--------------------------------------------------------------------------
  def param_variance(param_id)
    @param_variance[param_id]
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
  # * Set param_variance_factor
  #   This value will be used to effect the stats leveling curve
  #--------------------------------------------------------------------------
  def set_param_variance_factor(param_id,value)
    @param_variance_factor[param_id] = value.to_f
  end
  
  #--------------------------------------------------------------------------
  # * Get Scale Value
  #   This  will scale a value by the provide factor and current level
  #--------------------------------------------------------------------------
  def get_scale_value(scale_factor = 1.0,base_value=1,min_value=1.0)
    #dividing by x/0 is bad. this bypass the crash
    if scale_factor == 0
      return [base_value,min_value].max; 
    end
    return [((level-1)/scale_factor + 1)*base_value,min_value].max
  end
  
  #--------------------------------------------------------------------------
  # * Update param_leveled
  #   This will scale the enemy stats base on their level at the time of this
  #   being called
  #--------------------------------------------------------------------------
  def update_param_leveled
    for id in 0..7 do
      @param_leveled[id] = get_scale_value(param_scale_factor(id),enemy.params[id])
    end
  end
  
  #--------------------------------------------------------------------------
  # * apply_param_variance 
  #--------------------------------------------------------------------------
  def apply_param_variance
    for id in 0..7 do
      @param_variance[id]=((param_variance_factor(id)/100.0)*(rand()*2-1))+1
    end
  end
  
  #--------------------------------------------------------------------------
  # * refresh_params
  #   This calls all the dymanic params 
  #--------------------------------------------------------------------------
  def refresh_params(recover = true, reroll_variance = true)
    update_param_leveled
    if reroll_variance
      apply_param_variance
    end
    if recover
      @hp = mhp
      @mp = mmp
    end
  end
  #--------------------------------------------------------------------------
  # * Set Level
  #   For event scripts to call to set an enemy level
  #   Should only be used for enemies that stats are design to scale with level
  #--------------------------------------------------------------------------
  def set_level(new_level, recover = true, max_level = MAX_LEVEL)
    @level = [[new_level, max_level].min, 1].max
    refresh_params(recover,false)
  end
  
  #--------------------------------------------------------------------------
  # * (Overrding) Get Base Value of Parameter
  #--------------------------------------------------------------------------
  def param_base(param_id)
    [param_leveled(param_id).to_f * param_variance(param_id).to_f,1].max.to_i
  end
  
  #--------------------------------------------------------------------------
  # * (Overrding) Get Experience
  #--------------------------------------------------------------------------
  def exp
    value = get_scale_value(exp_scale_factor,enemy.exp,0)
    if $game_map.respond_to?(:exp_modifier)
      value *= $game_map.exp_modifier
    end
    if $game_troop.respond_to?(:exp_modifier)
      value *= $game_troop.exp_modifier
    end
    return value.floor 
  end
  #--------------------------------------------------------------------------
  # * (Overrding) Get Gold
  #--------------------------------------------------------------------------
  def gold
    value = get_scale_value(gold_scale_factor,enemy.gold,0)
    if $game_map.respond_to?(:gold_modifier)
      value *= $game_map.gold_modifier
    end
    if $game_troop.respond_to?(:gold_modifier)
      value *= $game_troop.gold_modifier
    end
    return value.floor
  end
  
  #--------------------------------------------------------------------------
  # * (Overrding) Transform
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    old_id = @enemy_id
    old_transform(enemy_id)
    if old_id  != enemy_id
      refresh_params
    end
  end
end
