#this is an example of remote trigging events without depending on autorun
#It currently only works for character events

#--------------------------------------------------------------------------
# * Event Triggers Module
#   this provides additional triggers and listerners
#--------------------------------------------------------------------------
module Event_Triggers
  #--------------------------------------------------------------------------
  # * Module Instance Variables
  #--------------------------------------------------------------------------
  @listeners = {}
  #common events would need a diffrent call system, so may not include it yet
  #@common_listeners = {} 
  @queue_triggers = []
  
  def self.debug
    puts " size test"
    print @listeners.size
  end
  
  def self.clear_listeners
    @listeners.clear 
  end
  
  def self.connect_to(id, event)
    if !event || !id; return; end
    if !@listeners[id]; @listeners[id] = []; end 
    if @listeners[id].include?(event); return; end
    @listeners[id].push(event)
    if $TEST
      puts ""
      print " id "; print id; print " "; print event; print " connected "
    end
  end
  
  def self.disconnect_from(id, event)
    if !@listeners[id] || !event; return; end
    @listeners[id].delete(event)
    if listeners[id].empty?
      @listeners.delete(id)
    end
  end
  
  def self.add_to_trigger_queue(id, run = false)
    if !@queue_triggers.include?(id)
      @queue_triggers.push(id)
      puts "adding " + id.to_s + " to queue " if $TEST
    end
    if run
      run_triggers
    end
  end
  
  def self.on_change(id = :update, run_now = false)
    if !@listeners[id]; return; end
    add_to_trigger_queue(id,run_now)
  end
  
  def self.run_triggers
    for trigger in @queue_triggers
      if @listeners[trigger]
        for event in @listeners[trigger]
          if event.respond_to?(:start)
            if event.trigger.to_i  > 1; return; end 
            event.start(trigger)
            puts "running : " + trigger.to_s if $TEST
            @queue_triggers.delete(trigger)
          else
            @listeners[trigger].delete(event)
            if listeners[trigger].empty?
              @listeners.delete(trigger)
            end
          end
        end
      end
    end
  end
end


class Game_Variables
  alias :old_setter_event_triggers :[]=
  def []=(variable_id, value)
    old_value = @data[variable_id]
    if old_value != value
      trigger_key = ("var_"+variable_id.to_s).to_sym
      Event_Triggers.on_change(trigger_key)
      Event_Triggers.on_change(:var,true)
    end
    old_setter_event_triggers(variable_id, value)
  end
end

class Game_Switches
  alias :old_setter_event_triggers :[]=
  def []=(switch_id, value)
    old_value = @data[switch_id]
    if old_value != value
      trigger_key = ("swi_"+switch_id.to_s).to_sym
      Event_Triggers.on_change(trigger_key)
      Event_Triggers.on_change(:swi,true)
    end
    old_setter_event_triggers(switch_id, value)
  end
end

class Game_SelfSwitches
  alias :old_setter_event_triggers :[]=
  def []=(key, value)
    old_value = @data[key]
    if old_value != value
      trigger_key = ("sswi_"+key.to_s).to_sym
      Event_Triggers.on_change(trigger_key)
      Event_Triggers.on_change(:sswi,true)
    end
    old_setter_event_triggers(key, value)
  end
end


class Game_Event < Game_Character
  alias old_initialize_event_triggers initialize
  alias old_start_event_triggers start
  
  attr_reader :remote_trigger 
  
  def connect_trig(event,trig_name="trig",include_base = true)
    trigger_key = trig_name.to_sym
    added = false
    if event.name.include?("*"+trig_name)
      if include_base && event.name.match(/\*#{trig_name}(?=$|\s)/)
        Event_Triggers.connect_to(trigger_key, self)
        added = true
      end
      for trig_scan_element in event.name.scan(/\*#{trig_name}(\d+)/i)
        if trig_scan_element.size < 1; next; end
        trig_id = trig_scan_element[0]
        if !trig_id; next; end
        trigger_key = (trig_name+"_"+trig_id).to_sym
        Event_Triggers.connect_to(trigger_key, self)
        added = true
      end
    end
    return added
  end
  
  def initialize(map_id, event)
    old_initialize_event_triggers(map_id, event)
    @remote_trigger = nil
    connect_trig(event,"var")
    connect_trig(event,"swi")
    connect_trig(event,"sswi")
    connect_trig(event,"init")
    connect_trig(event,"trig",false)
    
    
  end
  

  def start(remote_trigger_id = nil)
    if !@starting
      @remote_trigger = remote_trigger_id
    end
    old_start_event_triggers
  end
  
end


class Game_Map

  alias :old_refresh_event_triggers :refresh
  alias :old_setup_events_event_triggers :setup_events

  def refresh
    Event_Triggers.run_triggers
    old_refresh_event_triggers
  end
  def setup_events
    Event_Triggers.clear_listeners
    old_setup_events_event_triggers
    Event_Triggers.on_change(:init,true)
    if $TEST
      Event_Triggers.debug
    end
  end
end
