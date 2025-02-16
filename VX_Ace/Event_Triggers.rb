#--------------------------------------------------------------------------
# * Event Triggers Module
#   this provides additional triggers and listerners
#--------------------------------------------------------------------------
module Event_Triggers
  #--------------------------------------------------------------------------
  # * Module Instance Variables
  #--------------------------------------------------------------------------
  @listeners = [nil,[],[]] 
  @queue_triggers = []

  def self.connection_type_id(name)
    if [1,"variable","variables"].include?(id)
      return 1
    elsif [2,"switch","switches"].include?(id)
      return 2
    end
    return 0
  end
  
  def self.connect_to(id, event)
    if !@listeners[id] || !event; return; end
    if @listeners[id].include?(event); return; end
    @listeners[id].push(event)
    print " id "; print id; print " "; print event; print " connected "
  end
  
  def self.disconnect_from(id, event)
    if !@listeners[id] || !event; return; end
    @listeners[id].delete(event)
  end
  
  def self.add_to_trigger_queue(id)
    if !@queue_triggers.include?(id)
      @queue_triggers.push(id)
    end
  end
  
  def self.on_change(id = 0, index = 0, value = 0, old_value=0)
    if !@listeners[id]; return; end
    add_to_trigger_queue(id)
  end
  
  def self.run_triggers
    for trigger in @queue_triggers
      for event in @listeners[trigger]
        if event.respond_to?(:start)
          if event.trigger > 1; return; end 
          event.start
        else
          @listeners[id].delete(event)
        end
      end
    end
  end
end
