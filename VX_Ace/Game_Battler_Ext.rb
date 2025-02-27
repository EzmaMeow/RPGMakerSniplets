class Game_Battler < Game_BattlerBase
  
  alias :old_initialize :initialize
  
  #exposing these for caculation reasons
  attr_reader   :state_turns
  attr_reader   :state_steps
  
  def crit_damage
    return get_modifier(agi,200) + 1.5
  end
  
  def get_modifier(base_value,factor)
    return base_value.to_f/factor.to_f
  end
  
  #--------------------------------------------------------------------------
  # * Apply Critical
  #--------------------------------------------------------------------------
  def apply_critical(damage)
    modifier = crit_damage
    ([damage * modifier, damage].max).floor
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Critical Rate of Skill/Item
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    modifier = get_modifier((luk+agi)-(user.luk+user.agi),1000)
    item.damage.critical ? (user.cri + modifier) * (1 - cev) : 0
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Counterattack Rate for Skill/Item
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    modifier = get_modifier((luk+agi)-(user.luk+user.agi),1000)
    return 0 unless item.physical?          # Hit type is not physical
    return 0 unless opposite?(user)         # No counterattack on allies
    return cnt + modifier                   # Return counterattack rate
  end
  #--------------------------------------------------------------------------
  # * Calculate Hit Rate of Skill/Item
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    modifier = get_modifier((luk+agi)-(user.luk+user.agi),1000)
    rate = item.success_rate * 0.01     # Get success rate
    rate *= user.hit if item.physical?  # Physical attack: Multiply hit rate
    return rate + modifier              # Return calculated hit rate
  end
  #--------------------------------------------------------------------------
  # * Calculate Evasion Rate for Skill/Item
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    modifier = get_modifier((luk+agi)-(user.luk+user.agi),1000)
    return eva + modifier if item.physical? # Return evasion if physical attack
    return mev + modifier if item.magical?  # Return magic evasion if magic attack
    return 0
  end
end
