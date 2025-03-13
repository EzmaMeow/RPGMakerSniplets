#this is an example of appending to the save file as well as a way to store extra data

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
class Game_Interpreter
  
  def load_event_data(key="")
    return $game_meta.map_event_data(@map_id,key)
  end
    
  def save_event_data(value,key="")
    $game_meta.set_map_event_data(value,@map_id,key)
  end
  
end

#==============================================================================
# ** Game_Meta
#------------------------------------------------------------------------------
class Game_Meta
  def initialize
    @data = {}
    @map_data = [] 
  end
  
  ##NOTE: data is reserve for loose varibles. Usally not booleans 
  ##or ints
  #--------------------------------------------------------------------------
  # * Get data
  #--------------------------------------------------------------------------
  def data(key, default = nil)
    if @data[key]; return @data[key]; end
    return default
  end
  #--------------------------------------------------------------------------
  # * Set data
  #--------------------------------------------------------------------------
  def set_data(key, value)
    @data[key] = value
    on_change
  end
  ##NOTE: map_data is reserver for persistant map data.
  ##first index is event meta, second is for tile changes
  #--------------------------------------------------------------------------
  # * Get map_data 
  #--------------------------------------------------------------------------
  def map_data(map_id)
    if @map_data[map_id] == nil
      @map_data[map_id] = [{},{}]
    end
    return @map_data[map_id]
  end
  
  #Event data is for meta data of an event
  #will use key instead mixing key and event id since this may be used
  #to create dynamic events. If a static event need data, it can add its id to
  #the key
  def map_event_data(map_id,event_key="")
    return map_data(map_id)[0][event_key]
  end
  
  def set_map_event_data(value,map_id,event_key="")
    return if event_key == "" #should not allow empty keys
    map_data(map_id)[0][event_key] = value
    on_change
  end
  
  #--------------------------------------------------------------------------
  # * Processing When Setting Meta
  #--------------------------------------------------------------------------
  def on_change
    #$game_map.need_refresh = true
  end
  
end

#--------------------------------------------------------------------------
# * DataManager
#--------------------------------------------------------------------------
module DataManager
  class<<self
    alias :old_create_game_objects_data_ext :create_game_objects
    alias :old_make_save_contents_data_ext :make_save_contents
    alias :old_extract_save_contents_data_ext :extract_save_contents
  end
  
  #--------------------------------------------------------------------------
  # * Create Game Objects
  #--------------------------------------------------------------------------
  def self.create_game_objects
    old_create_game_objects_data_ext
    $game_meta = Game_Meta.new
  end
  
  #--------------------------------------------------------------------------
  # * Create Save Contents
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = old_make_save_contents_data_ext
    contents[:meta] = $game_meta
    return contents
  end
  #--------------------------------------------------------------------------
  # * Extract Save Contents
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    old_extract_save_contents_data_ext(contents)
    if contents[:meta]
      $game_meta = contents[:meta]
    end
  end
end
