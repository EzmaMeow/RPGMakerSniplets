#This is an example of switching leader while moving on the feild
#It switches base on a postion instead of pushing the party array back and forth
#only becasue it is easier, but may be improved in the future.
#NOTE: it could mess up ideal formation order
#there may be a way to have it change leader without touching formation order
#but require party leader def to be overriden and what ever renders the party follow
#sprites

class Scene_Map < Scene_Base
  alias :old_update_switch_member :update
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    input_handler
    old_update_switch_member
  end
  
  def input_handler
    return if $game_map.interpreter.running?
    if Input.trigger?(:L)
      if !@party_focus
        @party_focus = 1
      else
        @party_focus += 1
      end
      on_party_focus_changed
    elsif Input.trigger?(:R)
      if !@party_focus
        @party_focus = 3
      else
        @party_focus -= 1
      end
      on_party_focus_changed
      #refresh
    end
  end
  
  def on_party_focus_changed
    if !@party_focus; return; end
    if @party_focus <= 0
      @party_focus = $game_party.members.size - 1
    elsif @party_focus >= 4
      @party_focus = 1
    end
    if @party_focus > 0 && $game_party.members.size > 1
      $game_party.swap_order(0, @party_focus)
    end
  end
  
end
