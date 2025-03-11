##this provides a space to add text to in cases where either the message editor is too small 
#and a auto newline system is used or one want a single place to store all dialog

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

module Dialog_Handler
  
  def self.fetch(key="")
    return nil
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
  ])
  
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
  ])

  
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
