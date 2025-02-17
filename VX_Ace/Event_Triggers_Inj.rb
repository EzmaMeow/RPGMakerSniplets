#requires Event_Triggers

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

class Game_Event < Game_Character
  alias old_initialize initialize
  def initialize(map_id, event)
    old_initialize(map_id, event)
    
    if event.name.include?("*var")
      Event_Triggers.connect_to(0, self)
    end
    if event.name.include?("*swi")
      Event_Triggers.connect_to(1, self)
    end
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
    Event_Triggers.add_to_trigger_queue(0)
    Event_Triggers.add_to_trigger_queue(1)
    Event_Triggers.run_triggers
  end
end
