#NOTE: Requires Magic_Blood

#--------------------------------------------------------------------------
# * Game_BattlerBase
#--------------------------------------------------------------------------
class Game_BattlerBase
  
  alias old_skill_cost_payable? skill_cost_payable?  
  alias old_pay_skill_cost pay_skill_cost
  
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    if Magic_Blood.is_bloodmage?(@class_id)
      Magic_Blood.skill_cost_payable?(skill,self)
    else
      old_skill_cost_payable?(skill)
    end
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def pay_skill_cost(skill)
    if Magic_Blood.is_bloodmage?(@class_id)
      Magic_Blood.pay_skill_cost(skill,self)
    else
      old_pay_skill_cost(skill)
    end
  end
end
#--------------------------------------------------------------------------
# * Window_SkillList
#--------------------------------------------------------------------------
class Window_SkillList < Window_Selectable
  
  alias old_draw_skill_cost draw_skill_cost
  
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    if Magic_Blood.is_bloodmage?(@actor.class_id)
      Magic_Blood.draw_skill_cost(rect, skill,@actor,self)
    else
      old_draw_skill_cost(rect, skill)
    end
  end
end
