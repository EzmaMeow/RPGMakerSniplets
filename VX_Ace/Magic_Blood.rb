#optional: Uses Note_Reader if added

module Magic_Blood
  #--------------------------------------------------------------------------
  # * Constants
  #-------------------------------------------------------------------------- 
  BLOOD_MAGIC_TYPE_ID = 3           #Blood magic will be assign to this skill type
  MP_TO_HP_RATIO  = 10              #Blood mages can cast spells without mp
  BASE_HP_BONUS_RATE = 0.1          #this is the bonus cost(and power) from max hp
  
  @skills_extra_data = {}
  
  ##Getters for the specail stats. if Note_Reader is used, then @var=value;
  ##can be added to the skill notes to override the provided functions
  ##Due to skill notes note being acessable easly, Note Reader is used
  ##since it expose item notes publicly
  ##(issue is item class is RPG::Skill and I can not seem to acess its parent
  ##properties)
  def self.make_skill_data(skill)
    #NOTE: this will create a hash for each vaild skill that use this
    #it will fill it with the default values. This might not be desired
    #but can be removed by returning just the defaults. I may try to improve it
    @skills_extra_data[skill] = [
    MP_TO_HP_RATIO.to_f,
    BASE_HP_BONUS_RATE.to_f
    ]
  end
  
  def self.mp_to_hp_ratio(skill)
    if !@skills_extra_data[skill]
      make_skill_data(skill)
    end
    if defined?(Note_Reader)
      vars = Note_Reader.get_varibles(skill)
      if vars["mp_to_hp_ratio"] != nil
        @skills_extra_data[skill][0] = vars["mp_to_hp_ratio"].to_f
      end
    end
    return @skills_extra_data[skill][0]
  end
  
  def self.hp_bonus_rate(skill)
    if !@skills_extra_data[skill]
      make_skill_data(skill)
    end
    if defined?(Note_Reader)
      vars = Note_Reader.get_varibles(skill)
      if vars["hp_bonus_rate"] != nil
        @skills_extra_data[skill][1] = vars["hp_bonus_rate"].to_f
      end
    end
    return @skills_extra_data[skill][1]
  end
  
  #--------------------------------------------------------------------------
  # * Get a percent of the caster max hp to be used for bonus cost and power
  #   Note: the skill need to call this if it want to get the bonus damage
  #-------------------------------------------------------------------------
  def self.get_hp_bonus(caster,rate=BASE_HP_BONUS_RATE)
    return caster.param(0) * rate
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
    return (
      caster.skill_mp_cost(skill)* mp_to_hp_ratio(skill)
      + get_hp_bonus(caster,hp_bonus_rate(skill))
      ).floor
  end
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def self.skill_cost_payable?(skill,caster)
    hp_cost = get_hp_cost(skill,caster)
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
