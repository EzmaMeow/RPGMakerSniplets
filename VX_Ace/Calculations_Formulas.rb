class Formula
  #returns a value base on the ratio of the stat and max stat offset 
  #by the provided base.
  def self.get_modifier(stat, base = 1.0, max=255.0)
    return (stat.to_f/max.to_f) + base
  end
  
  #The default attack logic. It damage is modify around 0-2 times
  #base on the attack stat
  def self.attack(damage=1, attack=1, defence=0)
    return damage * get_modifier(attack-defence,1.0)
  end
  
  #An attack that damage scales off of atk stat
  def self.power_attack(power=1, attack=1, defence=0)
    return power * [(attack-defence),1].max
  end

end
