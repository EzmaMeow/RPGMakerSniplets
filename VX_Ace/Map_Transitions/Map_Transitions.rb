#This is an example of keeping the screen faded while the map run events for a few frame
#this could be modify to add loading screens and such, but for now it just to hide
#some map event setups.
#Note: Currently it do not pause movement, so the player may be able to move still

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  alias :old_initialize_map_trans :initialize
  alias :old_setup_map_trans :setup
  alias :old_update_map_trans :update
  
  attr_reader   :loading
  
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    old_initialize_map_trans 
    @loading = 0
  end
  
  #--------------------------------------------------------------------------
  # * load_delay
  #--------------------------------------------------------------------------
  def load_delay
    return 30
  end
  
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id)
    old_setup_map_trans (map_id)
    @loading = load_delay
    @screen.start_fadeout(1)
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update(main = false)
    old_update_map_trans(main)
    on_map_loading
  end
  
  #--------------------------------------------------------------------------
  # * on_map_loading
  #--------------------------------------------------------------------------
  def on_map_loading
    @loading -= 1 if @loading > 0
    #below is to fade back after staring/loading. It could be used
    #to auto fade in after setting loading in an event
    #NOTE: this works with whiteout, but it may be handling it incorrectly.
    @screen.start_fadein(30) if @loading == 1 && @screen.brightness != 255
  end
  
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map < Scene_Base 
  
  alias :old_start_map_trans :start
  alias :old_update_map_trans :update
  
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    old_start_map_trans
    @transfering = false
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    old_update_map_trans
    if @transfering
      on_transfering
    end
  end
  
  #--------------------------------------------------------------------------
  # * Player Transfer Processing
  #   Override to allow on_transfering to run untill it decide to
  #   Call post_transfer
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    @transfering = true
    on_transfering
  end
  
  #--------------------------------------------------------------------------
  # * on_transfering
  #   This is to handle any logic that need to run before post_transfer
  #   Currently it is used to delay the post transfer untill after the map
  #   finish loading.
  #--------------------------------------------------------------------------
  def on_transfering
    if $game_map
      if $game_map.loading <= 0
        @transfering = false
        post_transfer
      end
    else
      @transfering = false
      post_transfer
    end
  end
  
end
