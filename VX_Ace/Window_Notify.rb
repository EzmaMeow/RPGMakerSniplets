#Note: need to init this class to used as well as make sure update gets called
#(note: scenes may auto call update on instances var of theirs that are windows)
#Also add_notification() need to be called to display text. So this window may 
#need to be added to a global varible or similar to be acess via event

#TODO: figure out how borders and spacing works and add a function
#that adjust the text y value instead of using a static value

##this window used for handling timed notifcation that do not pause gameplay
class Window_Notify < Window_Base
    
  def initialize(x=0, y=0, width = Graphics.width, height = 64)
    super
    @window_width = width
    @window_height = height
    @display_time = 0 
    @queue = {} 
  end
    
  def displaying?
    visible && @display_time != 0
  end
    
  def clear_text
    contents.clear
  end
  
  ##This is called to add text to be displayed.
  def add_notification(text)
    if displaying?
      if @queue[text]
        @queue[text] = @queue[text] + 1
      else
        @queue[text] = 1
      end
    else
      display_text(text)
    end
  end
    
  def display_text(text)
    clear_text
    @display_time = 1
    draw_text(0, -14, width, height,text)
    if !visible
      show
    end
  end
    
  def update
    super
    if displaying?
      forward_time
    end
  end
    
  def forward_time
    if @display_time < 120+1
      @display_time += 1
    elsif @queue.empty?
      hide
      @display_time = 0
    else
      key = @queue.keys[0]
      value = @queue.delete(key)
      next_text = key.to_s 
      if value > 1
        next_text += " x" + value.to_s + ""
      end
      display_text(next_text)
    end
  end
end
