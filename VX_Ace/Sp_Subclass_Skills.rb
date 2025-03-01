#NOTE: Added the injections into this file. May split it later

#INJECTIONS
class Game_Actor < Game_Battler
  alias :old_use_item :use_item
  alias :old_initialize :initialize
  
  attr_accessor :subclass_levels
  
  def initialize(actor_id)
    old_initialize(actor_id)
    @subclass_levels = []
  end
    
  def use_item(item)
    old_use_item(item)
    if item.respond_to?(:stype_id)
      subclass_ids = Subclass_Skills.get_skill_subclass_ids(item.id)
      for subclass_id in subclass_ids
        Subclass_Skills.level_up(self, subclass_id)
      end
    end
  end
end

#SUBCLASSES
class Subclass
  attr_accessor :name
  attr_accessor :max_level
  attr_accessor :skills
  attr_accessor :skill_spacing
  attr_accessor :difficulty
  def initialize(name, skills=[], spacing = 5, difficulty = 10)
    @name = name
    @max_level = 99
    @skills = skills
    @skill_spacing = spacing
    @difficulty = difficulty
  end
  
  def get_skill_at_level(level)
    if level % @skill_spacing == 0
      return skill_id = @skills[level / @skill_spacing - 1]
    end
    return nil
  end
  
  def get_learnable_skills(level)
    learnable_skills = []
    for skill_index in 0..@skills.size-1
      skill_id = @skills[skill_index]
      if skill_id && level >= ((skill_index+1)*@skill_spacing)
        learnable_skills.push(skill_id)
      end
    end
    return learnable_skills
  end
  
end

#CORE
module Subclass_Skills
  
  @subclasses = [
    Subclass.new("Healing",[26,31,27,32,33,29,28,30,34]),
    Subclass.new("Fire",[51,nil,52,nil,53,nil,54]),
    Subclass.new("Ice",[55,nil,56,nil,57,nil,58]),
    Subclass.new("Lighting",[59,nil,60,nil,61,nil,62]),
    Subclass.new("Nature",[63,65,67,64,66,68])
  ]
  
  def self.get_skill_subclass_ids(skill_id)
    skills = [] #using array since there may be multi groups
    for subclass_id in 0..@subclasses.size-1
      subclass = @subclasses[subclass_id]
      if subclass
        if subclass.skills.include?(skill_id)
          skills.push(subclass_id)
        end
      end
    end
    return skills
  end
  
  def self.learn_skill_at_level(actor,id)
    subclass = @subclasses[id]
    return if !subclass || !actor.subclass_levels[id] 
    skill_id = subclass.get_skill_at_level(actor.subclass_levels[id])
    if skill_id 
      actor.learn_skill(skill_id)
    end
  end
  
  #this can be used to update skills if for some reason
  #the sublevel is set and need to update the skill list
  def self.learn_skills(actor,id)
    #TODO test this
    subclass = @subclasses[id]
    return if !subclass || !actor.subclass_levels[id]
    for skill_id in subclass.get_learnable_skills(actor.subclass_levels[id])
      actor.learn_skill(skill_id)
    end
  end
  
  #may be a bit misleading. roll for level up make more sence
  #but too long
  def self.level_up(actor, id, offset = 0)
    subclass = @subclasses[id]
    return false if !subclass 
    subclass_level = actor.subclass_levels[id]
    if !subclass_level
      subclass_level = 1
    end
    sucess_roll = subclass_level * subclass.difficulty + offset
    base = [subclass_level-actor.level,3].min
    if rand(sucess_roll).ceil >= (sucess_roll + base)
      actor.subclass_levels[id] = subclass_level + 1
      learn_skill_at_level(actor,id)
      return true
    end
    return false
  end
  
  
end
