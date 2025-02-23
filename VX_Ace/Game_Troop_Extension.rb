class Game_Troop < Game_Unit
  
  alias old_initialize initialize
  alias old_setup setup
  
  attr_accessor :min_level
  attr_accessor :max_level
  
  def initialize
    old_initialize
    @min_level = 1
    @max_level = 99
  end
  
  ##resets the level range. Should be called everytime a new map is loaded
  def setup_level
    @min_level = 1
    @max_level = 99
  end
  
  def setup(troop_id)
    old_setup(troop_id)
    setup_level
  end
  
  def default_level(level)
    [[level,@min_level].max,@max_level].min
  end
  
end
