#This is an example of switching leader while moving on the feild
#It switches base on a focus position, but do not effect party order

#--------------------------------------------------------------------------
#   Game_Follower
#   expose the member index so it can be changed
#--------------------------------------------------------------------------
class Game_Follower < Game_Character 
  attr_accessor :member_index
end
#--------------------------------------------------------------------------
#   Game_Followers
#   adding a function t0 allow to get a count of the current followers
#--------------------------------------------------------------------------
class Game_Followers
  def size
    return @data.size
  end
end

#--------------------------------------------------------------------------
#   Game_Player 
#--------------------------------------------------------------------------
class Game_Player < Game_Character
  alias :old_initialize_switch_member :initialize
  alias :old_update_switch_member :update
  alias :old_actor_switch_member :actor
  #if vehicle == nil #should run only if nil. may not be needed
  
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    old_initialize_switch_member
    @party_focus = 0
  end
  
  #--------------------------------------------------------------------------
  # * get the leading actor
  #   changed it to return the actor in focus
  #--------------------------------------------------------------------------
  def actor
    if @party_focus
      member = $game_party.battle_members[@party_focus]
      return member if member
    end
    return old_actor_switch_member
  end
  
  def update
    input_handler
    old_update_switch_member
  end
  #--------------------------------------------------------------------------
  # * input_handler
  #   listen to input changes (NOTE: should use a dedicated handler system)
  #--------------------------------------------------------------------------
  def input_handler
    return if $game_map.interpreter.running?
    if Input.trigger?(:L)
      @party_focus += 1
      if @party_focus >= $game_party.battle_members.size
        @party_focus = 0
      end
      on_focus_changed()
      refresh
    elsif Input.trigger?(:R)
      @party_focus -= 1
      if @party_focus < 0
        @party_focus = $game_party.battle_members.size - 1
      end
      on_focus_changed
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * on_focus_changed
  #   changes how the followers are ordered base on who is focused
  #--------------------------------------------------------------------------
  def on_focus_changed
    for i in 0..@followers.size-1
      follower = @followers[i]
      if i == @party_focus -1
        follower.member_index = 0
      else
        follower.member_index = i+1
      end 
    end
  end
end
