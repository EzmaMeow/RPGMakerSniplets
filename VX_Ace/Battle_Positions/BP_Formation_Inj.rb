#This is an example of how to assign positions with the formation menu

#==============================================================================
# ** Vocab
#==============================================================================
module Vocab
  def self.backrow;     "Back";   end
  def self.midrow;      "Mid";   end
  def self.frontrow;    "Front";   end 
end

#==============================================================================
# ** Scene_Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  alias :old_create_command_formation_ext :create_command_window
  def create_command_window
    old_create_command_formation_ext
    @command_window.set_handler(:option,  method(:command_option))
  end
  
  def command_option
    SceneManager.call(Scene_Option)
  end
  
  #--------------------------------------------------------------------------
  # * Formation [OK]
  #--------------------------------------------------------------------------
  def on_formation_ok
    if @status_window.pending_index >= 0
      $game_party.swap_order(@status_window.index,
                             @status_window.pending_index)
                             
      if @status_window.pending_index == @status_window.index
        actor = $game_party.members[@status_window.index]
        new_position = 0
        if actor.respond_to?(:change_position) && actor.respond_to?(:position)
          if actor.position < 2
            new_position = actor.position + 1
          end
          #formation_position is going to be used to store the position
          #assign with formations so one do not have to readjust it every battle
          if actor.respond_to?(:formation_position)
            actor.formation_position = new_position
          end
          actor.change_position(new_position)
          @status_window.redraw_item(@status_window.index)
        end
      end                       
                
      @status_window.pending_index = -1
      @status_window.redraw_item(@status_window.index)
    else
      @status_window.pending_index = @status_window.index
    end
    @status_window.activate
  end
end

#==============================================================================
# ** Window_MenuStatus
#==============================================================================
class Window_MenuStatus < Window_Selectable

  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    offset = 1
    if actor.respond_to?(:position)
      offset = 1 + actor.position
    end
    draw_actor_face(actor, rect.x + 5*offset, rect.y + 1, enabled)
    
    #test example of displaying row
    pos_text = ""
    if actor.respond_to?(:position)
      if actor.position >= 2
        pos_text = Vocab.backrow
      elsif actor.position == 1
        pos_text = Vocab.midrow
      else
        pos_text = Vocab.frontrow
      end
    end
    draw_text(rect.x + 108, rect.y + line_height*3, 120, line_height, pos_text)
    #draw_text(rect.x + 64, rect.y+32, 120, line_height, actor.formation_position.to_s, 2)
    
    draw_actor_simple_status(actor, rect.x + 108, rect.y + line_height / 2)
  end
end
