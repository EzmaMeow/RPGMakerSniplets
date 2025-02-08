
class Game_Enemy < Game_Battler
  
  alias old_initialize initialize
  
  attr_reader   :level                    # level

  #--------------------------------------------------------------------------
  # * Setup 
  #   Added level to enemies to prevent level breaking damage fomulas
  #   (also to allow enemies to simulate having levels)
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    old_initialize(index, enemy_id)
    @level = 1
  end
  
  #this is for events to call to prevent level from being
  #less than 1
  #TODO: can also add stat changes here so level can do more
  #than modify skill damages
  def set_level(new_level, max_level = 99)
    @level = [[new_level, max_level].min, 1].max
  end
end
