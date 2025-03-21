#This is for cases where one want to use a character set as a tileset of objects to be
#used as character. This like crates, barrels, or various decorations that could be interacted with
#but do not have rotations or animations. beow is an exampe of using it pick a random graphic
#get_character(0).set_graphic("!Objects1_Normal", rand(7), rand(3),rand(4))
#note "!Objects1_Normal" will need to be changed since it not part of the defaut graphics
#and is base on the 12 tile set of 6 sets.

class Game_CharacterBase
  
  alias :old_set_graphic_ext :set_graphic
  
  #--------------------------------------------------------------------------
  # * set graphic
  #   added the ability to set the patter(pat) (animation frame) and 
  #   direction(dir) as long as the value is in range
  #   patter need to be 0,1,2 or it will be set to the default of 1
  #   Direction iis base on (2,4,6,8), but this takes a value between 0-4
  #   instead so rand(4) can be used to pick a random direction.
  #   So dir needs be be between 0-4 to take effect.
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, pat= -1, dir = -1)
    old_set_graphic_ext(character_name, character_index)
    if pat >= 0
      #original_pattern is used if no animation is being handled
      @original_pattern = pat % 3
      #pattern is the one it displays
      @pattern = @original_pattern 
    end
    if dir >= 0
      @direction = (2 + (dir % 4)* 2)
    end
  end
end

# below is an example of acessing the first index of a character
# [index,pat,dir] left to right top to bottom
# [0,0,0] [0,1,0] [0,2,0]
# [0,0,1] [0,1,1] [0,2,1]
# [0,0,2] [0,1,2] [0,2,2]
# [0,0,3] [0,1,3] [0,2,3]
