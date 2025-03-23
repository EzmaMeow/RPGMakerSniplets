#Uses CharacterBase_Set_Graphic_Ext, but only for the example
#This is an example of adding : with some name to represent a function 
#to call. This is for init triggers and the name of this script may change
#to reflect this.
#This is meant to solve a problem where one have many events that need to run
#a setup logic, but setting them to autorun would cause lag and using Event Triggers
#will call a delay(and a slight, on call only, lag). This will allow the logic to be
#called without waiting on event nor as a event. This seems more efficent, but may
#cause lag if too much events use this. If that happen, using a dedicated system to
#log and run x amount per update should solve this. Considering this is for map set 
#up, the lag should not be an issue with a loading screen...unless it locks up the game.

class Game_Event < Game_Character
  alias :old_initialize_manual_triggers :initialize
  def initialize(map_id, event)
    old_initialize_manual_triggers(map_id, event)
    call_triggers(call_type=:init)
  end

  def call_triggers(call_type=:call)
    if @event.name.include?(":")
      for trig_scan_element in @event.name.scan(/:(\w+)/)
        call = trig_scan_element[0].to_sym
        next if !call
        send(call,call_type) if respond_to?(call)
      end
    end
  end
  
  def meow(call_type=nil)
    print "meow meow"
  end
  def random(call_type=nil)
    if call_type == :init
      set_graphic("!Objects1_Normal", rand(7), rand(3),rand(4))
    else
      print "I am only called on init" if $TEST
    end
  end
end
