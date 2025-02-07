class Magic_Blood
  
  #--------------------------------------------------------------------------
  # * Constants (Features)
  #--------------------------------------------------------------------------
  CLASS_ID  = 11                    #The default class to make use of blood magic
  MP_TO_HP_RATIO  = 10              #Blood mages can cast spells without mp
  MP_EFFICIENCY = 0.2               #Blood magic cost hp, mp just reduces it
  
  #--------------------------------------------------------------------------
  # * States if the class is a bloodmage
  #--------------------------------------------------------------------------
  def self.is_bloodmage?(class_id)
    class_id == CLASS_ID
  end
  
  def self.get_hp_cost(skill,caster)
    #need to see how much the mp reduce the hp cost
    remainer = caster.skill_mp_cost(skill) - caster.mp 
    print " | "
    print remainer
    if remainer < 0
      #mp was not used up, hp cost will be less
      return (caster.skill_mp_cost(skill)*MP_TO_HP_RATIO*MP_EFFICIENCY).floor 
    end
    return (remainer*MP_TO_HP_RATIO).floor
  end
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def self.skill_cost_payable?(skill,caster)
    hp_cost = get_hp_cost(skill,caster)
    caster.tp >= caster.skill_tp_cost(skill) && 
    (caster.mp >= caster.skill_mp_cost(skill) && caster.hp > hp_cost||
    caster.hp > hp_cost)
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def self.pay_skill_cost(skill,caster)
    caster.hp -= get_hp_cost(skill,caster)
    caster.mp -= caster.skill_mp_cost(skill)
    caster.tp -= caster.skill_tp_cost(skill)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def self.draw_skill_cost(rect, skill, actor, source)
    hp_cost = get_hp_cost(skill,actor)
    remainer = actor.skill_mp_cost(skill) - actor.mp
    mp_cost = [actor.skill_mp_cost(skill), remainer].max
    text = ""
    if hp_cost > 0
      source.change_color(source.hp_gauge_color2, source.enable?(skill))
      source.draw_text(rect, hp_cost, 2 )
      rect.x -= 8 * hp_cost.to_s.length + 8
      #text = hp_cost.to_s + "hp"
    end
    if actor.skill_tp_cost(skill) > 0
      source.change_color(source.tp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_tp_cost(skill), 2 )
      rect.x -= 8 *  actor.skill_tp_cost(skill).to_s.length + 8
      #text = actor.skill_tp_cost(skill).to_s + "sp " + text
    end
    if actor.skill_mp_cost(skill) > 0
      source.change_color(source.mp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_mp_cost(skill), 2 )
      #text = mp_cost.to_s + "mp " + text
    end
    #source.draw_text(rect, text, 2)
  end
end
