##this provides a space to add text to in cases where either the message editor is too small 
#and a auto newline system is used or one want a single place to store all dialog

class Game_Interpreter
  def start_dialog(dialog,index = 0)
    if dialog.is_a?(String)
      dialog = Dialog_Handler.fetch(dialog)
    end
    if dialog 
      return if !dialog.text(index)
      $game_message.clear
      $game_message.face_name = dialog.face_name
      $game_message.face_index = dialog.face_index
      $game_message.background = dialog.background
      $game_message.position = dialog.position
      Dialog_Handler.add_text(dialog.text(index))
      wait_for_message
    end
  end
  
end


class Dialog
  attr_accessor :face_name                # face graphic filename
  attr_accessor :face_index               # face graphic index
  attr_accessor :background               # background type
  attr_accessor :position                 # display position
  
  def initialize(text=[],face_name="",face_index=0,background=0,position=2)
    @face_name = face_name
    @face_index = face_index
    @background = background
    @position = position
    @text = text
    #TODO: move below elsewhere so it get called once(per load)
    if !$game_language
      $game_language = "eng"
    end
  end
  
  def text(index=0,language=$game_language)
    if @text[index]
      if @text[index][language]
        return @text[index][language]
      elsif @text[index].first
        return @text[index].first[1]
      end
    end
    return nil
  end
end

#links a dialog to an actor to simpify creation and sync changes
class Actor_Dialog < Dialog
  
  attr_accessor :actor_id
  
  def initialize(text=[],actor_id=0,background=0,position=2)
    @actor_id = actor_id
    super(text,"",0,background,position)
  end
  
  def face_name
    if $game_actors[@actor_id]
      return $game_actors[@actor_id].face_name
    end
    return @face_name 
  end
  def face_index
    if $game_actors[@actor_id]
      return $game_actors[@actor_id].face_index
    end
    return @face_index 
  end
end

module Dialog_Handler
  
  def self.fetch(key="")
    return nil
  end
  
  #this take a line of text and split it up if
  #the text length is too long for a line
  def self.add_text(text)
    max_line_size = 38
    current_line = ""
    full_size = $game_message.face_name == "" || $game_message.face_index < 0
    if full_size
      max_line_size = 48
    end
    if text.length > max_line_size
      text.split.each do |word|
        if current_line.length + word.length + (current_line.empty? ? 0 : 1) <= max_line_size
          current_line += (current_line.empty? ? "" : " ") + word
        elsif word.length > max_line_size
          $game_message.add(current_line)
          current_line = ""
        else
          $game_message.add(current_line)
          current_line = word
        end
      end
      if !current_line.empty?
        $game_message.add(current_line)
      end
    else
      $game_message.add(text)
    end
  end
  
end

##BELOW IS AN EXAMPLE ON ADDING DIALOG
#should be done in files below this:
module Dialog_Handler
  class<<self
    alias :old_fetch_for_example :fetch
  end
  
  @big_cat_dialog = Dialog.new([
    {"eng"=>"Meow I am the big cat."},
    {"eng"=>"Meow mew mew."},
    {"eng"=>"I am a lazy cat."}
  ],"Actor3",7)
  
  @small_cat_dialog = Dialog.new([
    {"eng"=>"Mew I am the small cat."},
    {"eng"=>"Dialog index is a chat session meow"},
    {"eng"=>"The eng key it to state the language mew."},
    {"eng"=>"So far only english is provided meow mew."},
    {"eng"=>"This system was designed to be used with an auto-newline system.
    Mew I may add as part of this system since all it dose is add text
    to the game_message base on character length. In other words, without it,
    this text will be cut off meow."},
    {"eng"=>"Also you can add the display info here, but its numbers and an
    a string. The Dialog declaration should explain enough. Currently
    that data is not use...like the text. So have to set it directly
    in the $game_message during script call. Meow I also plan on adding a 
    run function in the Dialog handler to simplify this, but mew is a lazy
    cat."}
  ],"Spiritual",4)

  
  def self.fetch(key="")
    print "MEOOOOOW : "; print key
    if key == "big_cat"
      return @big_cat_dialog
    elsif key == "small_cat"
      return @small_cat_dialog
    end
    return old_fetch_for_example(key)
  end
end
