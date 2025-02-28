#depends on Window_Option
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
