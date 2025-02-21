
#depends on:
  #Note_Reader
  #Magic_Blood
  #Game_Enemy_Extension

#note: this is to inject note reading for embeded varibles into existing custom classes and modules

#--------------------------------------------------------------------------
# * Note_Reader
#   Added instance vars for catching loaded data
#--------------------------------------------------------------------------
module Note_Reader
  #some data is only created for some entries, so it is easier just to
  #hash it once loaded. For extra data all entries may use, the class
  #should hold it, but can also call it here if easier. Hashes grow larger
  #in memory with size compare to arrays and class vars so it not ideal for an
  #for all case
  @data_skills={}
  
  def self.get_data_value(data_key, id, default, data_source)
    if !data_source[data_key] 
      data_source[data_key] = {}
    end 
    loaded_var = data_source[data_key][id]
    if loaded_var != nil 
      return loaded_var
    else 
      data_source[data_key][id] = get_variable(id,data_key,default)
      return data_source[data_key][id]
    end 
    return default
  end
  
  def self.get_skill_value(skill, id, default)
    get_data_value(skill, id, default,@data_skills)
  end
  #NOTE: might not use this and have enemy handle the value themselves
  #just an example for now
  def self.get_enemy_value(enemy, id, default)
    get_data_value(enemy, id, default,@data_enemies)
  end
end

#--------------------------------------------------------------------------
# * Magic_Blood
#--------------------------------------------------------------------------
module Magic_Blood
  class<<self
    alias old_mp_to_hp_ratio mp_to_hp_ratio
    alias old_hp_bonus_rate hp_bonus_rate
  end
  @skills_extra_data = {}
  
  def self.mp_to_hp_ratio(skill)
    value = old_mp_to_hp_ratio(skill)
    Note_Reader.get_skill_value(skill, "mp_to_hp_ratio", value).to_f
  end
  
  def self.hp_bonus_rate(skill)
    value = old_hp_bonus_rate(skill)
    Note_Reader.get_skill_value(skill, "hp_bonus_rate", value).to_f
  end
end


#--------------------------------------------------------------------------
# * Game_Enemy_Extension
#   allow level and realted stuff to be config in enemy notes
#--------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  alias old_party_average_level party_average_level
  def party_average_level(use_average = USE_PARTY_AVERAGE_LEVEL)
    #will check each source base on override order
    #override order: Troop, enemy, map where troop override all
    #but troop do not have notes, so the logic should be check in
    #old_party_average
    note_key = "scale_to_party"
    
    note_value = Note_Reader.get_variable(note_key,$game_map,nil)
    if !note_value.nil?
      use_average = note_value.downcase == "true"
    end
    note_value = Note_Reader.get_variable(note_key,enemy,nil)
    if !note_value.nil?
      use_average = note_value.downcase == "true"
    end

    old_party_average_level(use_average)
  end
end
