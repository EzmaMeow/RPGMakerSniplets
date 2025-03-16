#an example of adding actions when in the map.
#Currently only allow jumping over one cell long shallow water
#as long as there a place to jump

class Game_Player < Game_Character
  alias :old_update_field_actions :update
  alias :old_initialize_field_actions :initialize
  
  attr_accessor :field_jump_enable
  
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    old_initialize_field_actions
    @field_jump_enable = true
  end
  
  #--------------------------------------------------------------------------
  # * is jumping enable
  #--------------------------------------------------------------------------
  def can_jump?
    return @field_jump_enable
  end
  
  #--------------------------------------------------------------------------
  # * is cell a vaild jump_point
  #--------------------------------------------------------------------------
  def jump_point?(x=@x,y=@y,direction =@direction)
    x2 = $game_map.x_with_direction(x, direction)
    y2 = $game_map.y_with_direction(y, direction)
    return !passable?(x,y,direction) && $game_map.boat_passable?(x2, y2)
  end

  #--------------------------------------------------------------------------
  # * character_field_action
  #--------------------------------------------------------------------------
  def character_field_action
    #field jump
    if can_jump?
      distance_x = $game_map.x_with_direction(0, @direction)*2
      distance_y = $game_map.y_with_direction(0, @direction)*2
      point_acessable = passable?(@x+distance_x,@y+distance_y,@direction)
      if point_acessable && jump_point?()
        jump(distance_x,distance_y)
        #return since action was used up
        return true
      end
    end
  end

  #--------------------------------------------------------------------------
  # * on_action_pressed
  #--------------------------------------------------------------------------
  def on_action_pressed
    return if $game_map.interpreter.running?
    if Input.trigger?(:C)
      case @vehicle_type
      when :walk
        return if character_field_action
      when :boat
        #boat action
      when :ship
        #ship action
      when :airship
        #airship action
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    old_update_field_actions
    on_action_pressed
  end
end
