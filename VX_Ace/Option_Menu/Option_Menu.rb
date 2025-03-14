#This is an example of an option menu. 
#Note: the draw order and menu interface could be improved

#==============================================================================
# ** Vocab
#==============================================================================
module Vocab
  def self.option;      "Option";   end   
end
  
#==============================================================================
# ** Game_System
#==============================================================================
class Game_System
  alias :old_initialize_option_menu :initialize
  alias :old_on_before_save_option_menu :on_before_save
  alias :old_on_after_load_option_menu :on_after_load
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :remember_cursor
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    old_initialize_option_menu
    @saved_window_tone = nil
    @remember_cursor = true
  end
  
  #--------------------------------------------------------------------------
  # * Pre-Save Processing
  #--------------------------------------------------------------------------
  def on_before_save
    old_on_before_save_option_menu
    @saved_window_tone = [window_tone.red,window_tone.blue,window_tone.green]
  end
  #--------------------------------------------------------------------------
  # * Post-Load Processing
  #--------------------------------------------------------------------------
  def on_after_load
    old_on_after_load_option_menu
    if @saved_window_tone
      window_tone.red = @saved_window_tone[0]
      window_tone.blue = @saved_window_tone[1]
      window_tone.green = @saved_window_tone[2]
    end
  end
end

#==============================================================================
# ** Window_Option
#==============================================================================
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


#==============================================================================
# ** Scene_Option
#==============================================================================
class Scene_Option < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @command_window = Window_Option.new
    @display_window = Window_Selectable.new(
      @command_window.width, 0, Graphics.width-@command_window.width,
      Graphics.height
    )
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:increase,  method(:command_increase))
    @command_window.set_handler(:decrease,  method(:command_decrease))
    @command_window.set_handler(:remember_cursor,  method(:command_remember_cursor))
    redraw
  end
  
  def draw_value(name,value,index = 0)
    rect = @command_window.item_rect(index)
    @display_window.draw_text(
      0, rect.y, rect.width, rect.height,
      name +":", 2
    )
    @display_window.draw_text(rect.width, rect.y, rect.width, rect.height, value, 2)
  end
  
  def redraw
    @display_window.refresh
    draw_value("Red",$game_system.window_tone.red.floor,0)
    draw_value("Blue",$game_system.window_tone.blue.floor,1)
    draw_value("Green",$game_system.window_tone.green.floor,2)
    if $game_system.respond_to?(:remember_cursor)
      draw_value("Remember?",$game_system.remember_cursor,3)
    end
  end
  
  def command_increase
    if @command_window.index ==0
      if $game_system.window_tone.red < 255
        $game_system.window_tone.red += 1
        redraw
      end
    elsif @command_window.index ==1
      if $game_system.window_tone.blue < 255
        $game_system.window_tone.blue += 1
        redraw
      end
    elsif @command_window.index ==2
      if $game_system.window_tone.green < 255
        $game_system.window_tone.green += 1
        redraw
      end
    elsif @command_window.index ==3
      if !$game_system.remember_cursor
        $game_system.remember_cursor = true
        redraw
      end
    end
  end
  def command_decrease
    if @command_window.index ==0 
      if $game_system.window_tone.red > -255
        $game_system.window_tone.red -= 1
        redraw
      end
    elsif @command_window.index ==1 
      if $game_system.window_tone.blue > -255
        $game_system.window_tone.blue -= 1
        redraw
      end
    elsif @command_window.index ==2 
      if $game_system.window_tone.green > -255
        $game_system.window_tone.green -= 1
        redraw
      end
    elsif @command_window.index ==3
      if $game_system.remember_cursor
        $game_system.remember_cursor = false
        redraw
      end 
    end
  end
  
  def command_remember_cursor
    $game_system.remember_cursor = !$game_system.remember_cursor 
    redraw
    @command_window.activate
  end
end

#==============================================================================
# ** Window_MenuCommand
#==============================================================================

class Window_MenuCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # * add_original_commands
  #--------------------------------------------------------------------------
  alias :old_add_original_commands_ext :add_original_commands
  def add_original_commands
    old_add_original_commands_ext
    add_option_command
  end
  
  #--------------------------------------------------------------------------
  # * Add Option to Command List
  #--------------------------------------------------------------------------
  def add_option_command
    add_command(Vocab::option, :option, true)
  end
  
end
