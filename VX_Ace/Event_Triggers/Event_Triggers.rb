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
  @common_listeners = {} 
  @queue_triggers = []
  
  def self.debug
    puts " size test"
    print @listeners.size
  end

  #assign one common event to a trigger symbol. 
  #This do not check if it an autorun, so try not to assign
  #autoruns since it most likly will be redundant.
  def self.assign_common_event(common_event_id,trigger)
    return if !common_event_id || !trigger
    @common_listeners[trigger] = common_event_id
  end
  
  def self.clear_listeners
    @listeners.clear 
  end

  #start the common event that is link to the trigger
  #it should run before the other events right after the trigger
  #is triggered.
  def self.start_common(trigger)
    return false if !@common_listeners[trigger]
    common_event = $data_common_events[@common_listeners[trigger]]
    return false if !common_event
    interpreter = Game_Interpreter.new(1)
    interpreter.setup(common_event.list, 0)
    if interpreter.respond_to?(:run)
      interpreter.run
      return true
    end
    return false
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
  
  #id need to be a symbol. run_now it to have the event flag now
  def self.on_change(id = :update, run_now = false)
    if !@listeners[id]; return; end
    start_common(id) #will start it now and start it first
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
      Event_Triggers.on_change(:var)
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
      Event_Triggers.on_change(:swi)
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
      Event_Triggers.on_change(:sswi)
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
    connect_trig(event,"var") #var change
    connect_trig(event,"swi") #switch change
    connect_trig(event,"sswi") #any self switch change
    connect_trig(event,"init") #start of map
    connect_trig(event,"reg") #player map region change
    connect_trig(event,"ttag") #player tile tag change
    connect_trig(event,"trig",false) #custom trigger. requires id like trig1
    
    
  end
  

  def start(remote_trigger_id = nil)
    if !@starting
      @remote_trigger = remote_trigger_id
    end
    old_start_event_triggers
  end
  
end


class Game_Map

  alias :old_update_event_triggers :update
  alias :old_setup_events_event_triggers :setup_events

  def update(main = false)
    Event_Triggers.run_triggers if main
    old_update_event_triggers(main)
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

class Game_CharacterBase

  alias :old_update_move_event_triggers :update_move
 
  #exposing them so they could be read
  #if acess before on_move is called
  #or to be change to force a behavior
  attr_accessor :last_region_id
  attr_accessor :last_terrain_tag
  
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  def update_move
    old_update_move_event_triggers
    on_move
  end

  #calls additial checks on move
  def on_move
    if region_id != @last_region_id
      on_region_entered
      @last_region_id = region_id
    end
    if terrain_tag != @last_terrain_tag
      on_terrain_tag_entered
      @last_terrain_tag = terrain_tag
    end
  end
  #self trigger for region change
  def on_region_entered
    #placeholder. player will use this, but it here 
    #incase others want to listen to it via script
  end
  #self trigger for terrain tag change
  def on_terrain_tag_entered
    #placeholder. player will use this, but it here 
    #incase others want to listen to it via script
  end


  
    #NOTE: can add more triggers in a similar way
    #but since we catch their old value, it may not be
    #ideal to add them unless they are needed
    #all the base func in character could be
    #move to player if characters will never make use if it
    #$game_map.ladder?(@x, @y)
    #$game_map.bush?(@x, @y)
    #there can be more. there tile types (hills, shallow water)
    #but they are a bit more difficult to acess, but could be exposed
    #if needed

end

class Game_Player < Game_Character
  
  def on_region_entered
    trigger_key = ("reg_"+region_id.to_s).to_sym
    Event_Triggers.on_change(trigger_key)
    Event_Triggers.on_change(:reg)
  end
  
  def on_terrain_tag_entered
    trigger_key = ("ttag_"+terrain_tag.to_s).to_sym
    Event_Triggers.on_change(trigger_key)
    Event_Triggers.on_change(:ttag)
  end

end
