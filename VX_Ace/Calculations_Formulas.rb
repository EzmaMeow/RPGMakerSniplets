class Formula
  
  def self.get_modifier(stat, base = 1.0, max=255.0)
    return (stat.to_f/max.to_f) + base
  end

  def self.basic_attack(damage, attack, defence)
    return damage * get_modifier(attack-defence,1.0)
  end

end
