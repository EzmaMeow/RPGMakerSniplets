
# * INJECTIONS  * 

#--------------------------------------------------------------------------
# * Game_BattlerBase
#--------------------------------------------------------------------------
class Game_BattlerBase
  
  alias :old_skill_cost_payable_blood_magic? :skill_cost_payable?  
  alias :old_pay_skill_cost_blood_magic :pay_skill_cost

  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    if Blood_Magic.is_blood_magic?(skill)
      Blood_Magic.skill_cost_payable?(skill,self)
    else
      old_skill_cost_payable_blood_magic?(skill)
    end
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def pay_skill_cost(skill)
    if Blood_Magic.is_blood_magic?(skill)
      Blood_Magic.pay_skill_cost(skill,self)
    else
      old_pay_skill_cost_blood_magic(skill)
    end
  end
end

#--------------------------------------------------------------------------
# * Window_SkillList
#--------------------------------------------------------------------------
class Window_SkillList < Window_Selectable
  
  alias :old_draw_skill_cost_blood_magic :draw_skill_cost
  
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    if Blood_Magic.is_blood_magic?(skill)
      Blood_Magic.draw_skill_cost(rect, skill,@actor,self)
    else
      old_draw_skill_cost_blood_magic(rect, skill)
    end
  end
end

# * Base  * 

module Blood_Magic
  #--------------------------------------------------------------------------
  # * Constants
  #-------------------------------------------------------------------------- 
  BLOOD_MAGIC_TYPE_ID = 3     #Blood magic will be assign to this skill type
  HP_COST = 0                 #The base hp cost to cast a skill
  HP_COST_RATE = 0.075          #how much of hp will be added to the cost
  MHP_COST_RATE = 0.025         #how much of mhp will be added to the cost
  
  def self.hp_cost(skill)
    return HP_COST.to_f
  end
  
  def self.hp_cost_rate(skill)
    return HP_COST_RATE.to_f
  end
  
  def self.mhp_cost_rate(skill)
    return MHP_COST_RATE.to_f
  end
  
  #--------------------------------------------------------------------------
  # * Get a percent of the caster max hp to be used for bonus cost and power
  #   Note: the skill need to call this if it want to get the bonus damage
  #-------------------------------------------------------------------------
  def self.get_hp_bonus(caster, skill_id = nil)
    skill = nil
    #use the skill if skill id is provided
    if skill_id
      skill = $data_skills[skill_id]
      if skill
        return get_hp_cost(skill,caster)
      end
    #else try to find the last skill
    #since actions is an array(?), it may not be safe
    else
      for action in caster.actions
        skill = action.item 
        if skill
          return get_hp_cost(skill,caster)
        end
      end
    end
    #will use the default if all else fails
    cost = HP_COST
    cost += HP_COST_RATE*caster.hp
    cost += MHP_COST_RATE*caster.mhp
    return cost
  end
  
  #--------------------------------------------------------------------------
  # * States if the skill is blood magic
  #--------------------------------------------------------------------------
  def self.is_blood_magic?(skill)
    skill.stype_id == BLOOD_MAGIC_TYPE_ID 
  end
  #--------------------------------------------------------------------------
  # * get the hp cost of casting a blood spell
  #--------------------------------------------------------------------------
  def self.get_hp_cost(skill,caster)
    cost = hp_cost(skill)
    cost += hp_cost_rate(skill) * caster.hp.to_f
    cost += mhp_cost_rate(skill) * caster.mhp.to_f
    return cost.floor
  end
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def self.skill_cost_payable?(skill,caster)
    return false if caster.hp <= get_hp_cost(skill,caster)
    return false if caster.tp < caster.skill_tp_cost(skill)
    return false if caster.mp < caster.skill_mp_cost(skill)
    return true
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def self.pay_skill_cost(skill,caster)
    caster.hp -= get_hp_cost(skill,caster)
    caster.tp -= caster.skill_tp_cost(skill)
    caster.mp -= caster.skill_mp_cost(skill)
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
    end
    if actor.skill_mp_cost(skill) > 0
      source.change_color(source.mp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_mp_cost(skill), 2 )
      rect.x -= 8 *  actor.skill_mp_cost(skill).to_s.length + 8
    end
    if actor.skill_tp_cost(skill) > 0
      source.change_color(source.tp_cost_color, source.enable?(skill))
      source.draw_text(rect, actor.skill_tp_cost(skill), 2 )
      rect.x -= 8 *  actor.skill_tp_cost(skill).to_s.length + 8
    end
  end
end
