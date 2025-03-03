#requires Event_Triggers

#NOTE: events get updated on map refresh, so this system is more for
#cases where more complex conditions need to be checked or logic need to
#run on that state change.

class Game_Variables
  alias :old_setter :[]=
  def []=(variable_id, value)
    old_value = @data[variable_id]
    old_setter(variable_id, value)
    if old_value != value
      Event_Triggers.on_change(0,variable_id,value,old_value)
    end
  end
end

class Game_Switches
  alias :old_setter :[]=
  def []=(switch_id, value)
    old_value = @data[switch_id]
    old_setter(switch_id, value)
    if old_value != value
      Event_Triggers.on_change(1,switch_id,value,old_value)
    end
  end
end

class Game_SelfSwitches
  alias :old_setter :[]=
  def []=(key, value)
    old_value = @data[key]
    old_setter(key, value)
    if old_value != value
      Event_Triggers.on_change(2,key,value,old_value)
    end
  end
end

class Game_Event < Game_Character
  alias old_initialize initialize
  alias old_start start
  
  #call `$game_map.events[@event_id].remote_trigger >= 0` in condition script
  #to see if the event was remotely triggered.
  attr_reader :remote_trigger 
  
  def initialize(map_id, event)
    old_initialize(map_id, event)
    @remote_trigger = -1
    if event.name.include?("*var")
      Event_Triggers.connect_to(0, self)
      Event_Triggers.add_to_trigger_queue(0)
    end
    if event.name.include?("*swi")
      Event_Triggers.connect_to(1, self)
      Event_Triggers.add_to_trigger_queue(1)
    end
    if event.name.include?("*sswi")
      Event_Triggers.connect_to(2, self)
      Event_Triggers.add_to_trigger_queue(2)
    end
    if event.name.include?("*init")
      Event_Triggers.connect_to(3, self)
      Event_Triggers.add_to_trigger_queue(3)
      
    end
    if event.name.include?("*trig")
      for trig_scan_element in event.name.scan(/\*(?:trig)(\d+)/i)
        trig_id = trig_scan_element[0].to_i
        if !trig_id; next; end
        if !Event_Triggers.create_trigger(trig_id); next; end
        Event_Triggers.connect_to(trig_id, self)
      end
    end
  end
  
  #added a remote trigger identifier to help guess what
  #trigger the event. it will use the trigger id so default
  #need to be one less (-1)
  def start(remote_trigger_id = -1)
    if !@starting || (remote_trigger_id == -1 && @remote_trigger != -1)
      #only set it if it is not running or default trigger happens
      #so the remote trigger do not override touch or action events on accident
      @remote_trigger = remote_trigger_id
    end
    old_start
  end
  
end


class Game_Map
  alias old_refresh refresh
  alias old_setup_events setup_events
  
  def refresh
    Event_Triggers.run_triggers
    old_refresh
  end
  
  def setup_events
    old_setup_events
    Event_Triggers.run_triggers
  end
end
