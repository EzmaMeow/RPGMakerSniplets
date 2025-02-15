module Story
  
  #NOTE: How to use:
  #This is a base to maintain story stats without a ton of paralle events
  #Additional logic is needed base on needs of a story, but this come
  #with an state change trigger system. To set it up, make sure to link
  #STATES_VARS(`state_id`) to a game varible id that is either unused or reserver for the 
  #main story progression. this value should increase by one for every step
  #in the story
  
  #Then to link events to the notify system:
    #Note: something needs to call Story.set_state(`an int representing the state`)
    #for the notify system to work on state changes. Can also just call
    #Story.notify(`state_id`) when ever the state change as well
  
    #add : Story.add_to_notify($game_map.events[`event_id`],`state_id`)
    #for each event that need to listen to state change
    #then call Story.notify(`state_id`) after all are connected to have them
    #sync to the state.
    #to a autorun event and make sure to disable that page after the first run
    
    #the events added need to not be on an autorun(it beats the purpous of this
    #system) and may be best to set the trigger to player action.
    #this event should check the state either directly or with Story.state(state_id`)
    #and should call Story.remove_from_notify(self) when they are done ore
    #being erase. Ideally they should be removed once their ref is null, 
    #but manually removing them is a failsafe incase their ref dose not get nulled.
  
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  ##link an id with a $game.variables id
  STATES_VARS = {1=>1}
  
  #--------------------------------------------------------------------------
  # * Module Instance Variables
  #--------------------------------------------------------------------------
  @listening_events = {}  #an hash of arrays. Key is an 
  
  #--------------------------------------------------------------------------
  # * Notify system
  #--------------------------------------------------------------------------
  
  def self.add_to_notify(event,id=1)
    if !@listening_events[id]
      @listening_events[id] = []
    end 
    if @listening_events[id].include?(event)
      return
    end
    @listening_events[id].push(event)
  end
  
  def self.remove_from_notify(event,id=1)
    if !@listening_events[id]
      return
    end
    @listening_events[id].delete(event)
    if @listening_events[id].empty?
      @listening_events.delete(id)
    end
  end
  
  def self.clear_notify(event,id=1)
    if !@listening_events[id]
      return
    end
    @listening_events[id].clear
    @listening_events.delete(id)
  end
  
  def self.notify(id=1)
    if !@listening_events[id]
      return
    end
    for event in @listening_events[id]
      if event.respond_to?(:start)
        event.start
      else
        @listening_events[id].delete(event)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * run additional logic base on the id
  #   as well as notify listening event of a state change
  #--------------------------------------------------------------------------
  def self.notify_state_change(value=0,old_value=0,id=1)
    #Note: can add additonal logic here
    notify(id)
  end 
  
  #--------------------------------------------------------------------------
  # * Get the game state variables based on the provided key
  #   id 1 should point to the default story state
  #--------------------------------------------------------------------------
  def self.state(id=1)
    if STATES_VARS[id] 
      $game_variables[STATES_VARS[id]]
    else
      0
    end
  end
  #--------------------------------------------------------------------------
  # * Set the game state variables based on the provided key
  #--------------------------------------------------------------------------
  def self.set_state(value=0,id=1)
    state_id = STATES_VARS[id] 
    if state_id 
      old_value = $game_variables[state_id]
      $game_variables[state_id] = value
      if value != old_value
        notify_state_change(value,old_value,id)
      end
    end
  end 
end
