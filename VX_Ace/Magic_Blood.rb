class Magic_Blood
  
  #--------------------------------------------------------------------------
  # * Constants
  #-------------------------------------------------------------------------- 
  MP_TO_HP_RATIO  = 10              #Blood mages can cast spells without mp
  HP_TO_POWER_RATIO = 250           #Higher the HP cost, the better the dmg
  
  BLOOD_MAGIC_SKILLS_START = 127   #to reduce stack reading, can provide a range
  BLOOD_MAGIC_SKILLS_END = 129     #but after the range, will need to add to stack
  BLOOD_MAGIC_SKILLS = [127]       #uses mp_to_hp ratio for hp cost
  
  #--------------------------------------------------------------------------
  # * States if the skill is blood magic
  #--------------------------------------------------------------------------
  def self.is_blood_magic?(skill)
    if skill.id >= BLOOD_MAGIC_SKILLS_START && skill.id <= BLOOD_MAGIC_SKILLS_END
      true
    else
      BLOOD_MAGIC_SKILLS.include?(skill.id)
    end
  end
  #--------------------------------------------------------------------------
  # * get the hp cost of casting a blood spell
  #--------------------------------------------------------------------------
  def self.get_hp_cost(skill,caster)
    return caster.skill_mp_cost(skill)*MP_TO_HP_RATIO
  end
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def self.skill_cost_payable?(skill,caster)
    hp_cost = get_hp_cost(skill,caster)
    #NOTE: not checking mp since blood magic use hp to cast
    caster.tp >= caster.skill_tp_cost(skill) && caster.hp > hp_cost
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def self.pay_skill_cost(skill,caster)
    caster.hp -= get_hp_cost(skill,caster)
    caster.tp -= caster.skill_tp_cost(skill)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def self.draw_skill_cost(rect, skill, actor, source)
    hp_cost = get_hp_cost(skill,actor)
    text = ""
    if hp_cost > 0
      source.change_color(source.hp_gauge_color2, source.enable?(skill))
      source.draw_text(rect, hp_cost, 2 )
      rect.x -= 8 * hp_cost.to_s.length + 8
    elsif actor.skill_mp_cost(skill) > 0
      source.change_color(source.mp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_mp_cost(skill), 2 )
    end
    if actor.skill_tp_cost(skill) > 0
      source.change_color(source.tp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_tp_cost(skill), 2 )
      rect.x -= 8 *  actor.skill_tp_cost(skill).to_s.length + 8
    end
  end
end
