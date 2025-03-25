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
    @preparing_jump = nil
  end
  
  #can be used to check for flags to enable and disable jumpping
  def can_jump?
    return @field_jump_enable
  end
  
  #check if the point is block by something that can be jump over
  def jump_point?(x=@x,y=@y,direction =@direction)
    x2 = $game_map.x_with_direction(x, direction)
    y2 = $game_map.y_with_direction(y, direction)
    return !passable?(x,y,direction) && $game_map.boat_passable?(x2, y2)
  end
  
  def character_field_action
    #field jump
    if can_jump? && !preparing_jump?
      distance_x = $game_map.x_with_direction(0, @direction)*2
      distance_y = $game_map.y_with_direction(0, @direction)*2
      point_acessable = passable?(@x+distance_x,@y+distance_y,1)
      #todo: add more cases
      if point_acessable && jump_point?()
        if followers.visible
          @preparing_jump = [true,distance_x,distance_y,0]
        else
          @preparing_jump = [false,distance_x,distance_y,0]
        end
        return true
      end
    end
  end
  
  def preparing_jump?
    return @preparing_jump != nil
  end
  def preparing_jump_update
    return if @preparing_jump == nil
    if @preparing_jump[0]
      if @preparing_jump[3] == 0
        @followers.gather
        @preparing_jump[3] = 1
      elsif @preparing_jump[3] == 1
        if !@followers.gathering?
          @preparing_jump[3] = 2
          $game_player.followers.visible = false
          refresh
        end
      elsif @preparing_jump[3] == 2
        jump(@preparing_jump[1],@preparing_jump[2])
        @followers.each do |follower|
          follower.moveto(@x,@y)
        end
        @preparing_jump[3] = 3
      elsif @preparing_jump[3] == 3
        if !jumping?
          @preparing_jump[3] = 4
        end
      elsif @preparing_jump[3] == 4
        $game_player.followers.visible = true
        refresh
        @preparing_jump = nil
      end
    else
      jump(@preparing_jump[1],@preparing_jump[2])
      @preparing_jump = nil
    end
  end
  
  
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
    preparing_jump_update
    on_action_pressed
  end
end
