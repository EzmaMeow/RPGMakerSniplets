
#depends on Magic_Blood

#note: this is to inject note reading for embeded varibles into existing custom classes and modules

module Magic_Blood
  class<<self
    #NOTE: put alias in this block if needed
    #currenly overriding the functions for now
  end
  
  @skills_extra_data = {}
  
  
  def self.fetch_skill_data(skill, id, default)
    if defined?(Note_Reader) 
      if !@skills_extra_data[skill] 
        @skills_extra_data[skill] = {}
      end 
      loaded_var = @skills_extra_data[skill][id]
      if loaded_var != nil 
        return loaded_var
      else 
        vars = Note_Reader.get_varibles(skill)
        if vars[id] != nil 
          @skills_extra_data[skill][id] = vars[id].to_f
          return vars[id].to_f
        end 
      end 
    end
    return default.to_f
  end
  
  def self.mp_to_hp_ratio(skill)
    return fetch_skill_data(skill, "mp_to_hp_ratio", MP_TO_HP_RATIO)
  end
  
  def self.hp_bonus_rate(skill)
    return fetch_skill_data(skill, "hp_bonus_rate", BASE_HP_BONUS_RATE)
  end
  
end
