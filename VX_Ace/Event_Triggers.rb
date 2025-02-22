#--------------------------------------------------------------------------
# * Event Triggers Module
#   this provides additional triggers and listerners
#--------------------------------------------------------------------------
module Event_Triggers
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  #This will ignore varibles and switches of the listed indexes from staring events
  BLACKLIST_VAR_IDS = [[],[],[]]
  RESERVE_TRIGGERS = 3 
  MAX_TRIGGERS = 10 #this is to prevent accident expansion. Increase as needed
  
  #--------------------------------------------------------------------------
  # * Module Instance Variables
  #--------------------------------------------------------------------------
  @listeners = [[],[],[],[]]
  @queue_triggers = []
  
  #will only work with the declare types
  def self.connection_type_id(name)
    if [0,"variable","variables","var"].include?(id)
      return 0
    elsif [1,"switch","switches","swi"].include?(id)
      return 1
    elsif [2,"self_switch","self_switches","sswi"].include?(id)
      return 2
    elsif [3,"init","start","map","ini"].include?(id)
      return 3
    end
    
    return 0
  end
  
  def self.connect_to(id, event)
    if !@listeners[id] || !event; return; end
    if @listeners[id].include?(event); return; end
    @listeners[id].push(event)
    puts ""
    print " id "; print id; print " "; print event; print " connected "
  end
  
  def self.disconnect_from(id, event)
    if !@listeners[id] || !event; return; end
    @listeners[id].delete(event)
  end
  
  def self.add_to_trigger_queue(id, run = false)
    if !@queue_triggers.include?(id)
      @queue_triggers.push(id)
    end
    #will run triggers. this should be true only with custom triggers
    if run
      run_triggers
    end
  end
  
  def self.create_trigger(id = RESERVE_TRIGGERS+1)
    if id <= RESERVE_TRIGGERS
      puts "unable to create trigger. The id is reserver for built in triggers"
      return false
    end
    if id > MAX_TRIGGERS
      puts "unable to create new trigger id. Increase MAX_TRIGGERS if more are needed"
      return false
    end
    if !@listeners[id]
      @listeners[id] = []
    end
    return true
  end
  
  def self.on_change(id = 0, index = 0, value = 0, old_value=0)
    if BLACKLIST_VAR_IDS[id].include?(index); return; end
    if !@listeners[id]; return; end
    add_to_trigger_queue(id)
  end
  
  def self.run_triggers
    for trigger in @queue_triggers
      if @listeners[trigger]
        for event in @listeners[trigger]
          if event.respond_to?(:start)
            if event.trigger.to_i  > 1; return; end 
            event.start(trigger)
            @queue_triggers.delete(trigger)
          else
            @listeners[trigger].delete(event)
          end
        end
      end
    end
  end
end
