class Window_Option < Window_Command
  
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_commands
  end
  
  #--------------------------------------------------------------------------
  # * Add Option to Command List
  #--------------------------------------------------------------------------
  def add_commands
    add_command("Window Color R", :window_color, true)
    add_command("Window Color B", :window_color, true)
    add_command("Window Color G", :window_color, true)
    add_command("Remember Cursor", :remember_cursor, $game_system.respond_to?(:remember_cursor))
  end
  
  def update
  super
    if Input.press?(:LEFT)
      call_handler(:decrease)
    elsif Input.press?(:RIGHT)
      call_handler(:increase)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)#(0, 0, Graphics.width, Graphics.height)
    refresh
    activate
  end
end
