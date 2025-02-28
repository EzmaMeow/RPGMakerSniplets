
class Game_System
  alias :old_initialize :initialize
  alias :old_on_before_save :on_before_save
  alias :old_on_after_load :on_after_load
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :remember_cursor
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    old_initialize
    @saved_window_tone = nil
    @remember_cursor = true
  end
  
  #--------------------------------------------------------------------------
  # * Pre-Save Processing
  #--------------------------------------------------------------------------
  def on_before_save
    old_on_before_saved
    @saved_window_tone =[window_tone.red,window_tone.blue,window_tone.green]
  end
  #--------------------------------------------------------------------------
  # * Post-Load Processing
  #--------------------------------------------------------------------------
  def on_after_load
    old_on_after_load
    if @saved_window_tone
      window_tone.red = @saved_window_tone[0]
      window_tone.blue = @saved_window_tone[1]
      window_tone.green = @saved_window_tone[2]
    end
  end
  
end
