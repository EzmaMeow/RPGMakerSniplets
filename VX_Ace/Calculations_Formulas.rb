class Formula
  
  #returns a value base on the ratio of the stat and max stat offset 
  #by the provided base.
  def self.get_modifier(stat, base = 1.0, max=255.0)
    return (stat.to_f/max.to_f) + base
  end
  
  #get a value of the stat if scaled by the level
  #Note: max_level do not need to be the max level
  #setting it to 50 mean that it will return the stat value at 50
  #and almost double it at lvl 99
  def self.get_lvl_scaled_stat(stat, level =1.0,max_level=99)
    return [get_modifier(level, 0, max_level)*stat,1].max
  end
  
  #The default attack logic. It damage is modify around 0-2 times
  #base on the attack stat.
  def self.attack(damage=1, attack=1, defence=0, level=1)
    return (damage * get_modifier(attack-defence,1.0) * level).floor
  end
  
  #An attack that damage scales off of atk stat
  #scaling_factor is the level at which the skill get bonus damage from level
  #base on that ratio
  def self.power_attack(power=1, attack=1, defence=0, level=1, scaling_factor = 10)
    scaling =(level.to_f - 1.0)/scaling_factor.to_f + 1.0
    return (power * [(attack-defence),1].max * scaling).floor
  end
  
  #This one focus on doing a fix damage plus scaled damage
  def self.magic_attack(power=1, magic=1, level=1, scaling_factor = 10)
    scaling =(level.to_f - 1.0)/scaling_factor.to_f + 1.0
    return [power + (magic * scaling).floor,0.0].max
  end

  
  #these are compress damage formula that may be reuse a lot
  def self.basic_attack(base_damage,a, b, v)
    return attack((a.atk/15)+base_damage,a.atk,b.def,a.level)
  end
end
