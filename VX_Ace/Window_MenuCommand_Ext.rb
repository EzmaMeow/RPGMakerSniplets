##Adds  defaults terms to Vocab
module Vocab
  def self.option;      "Option";   end  
end
#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    add_formation_command
    add_original_commands
    add_save_command
    add_option_command
    add_game_end_command
  end
  
  #--------------------------------------------------------------------------
  # * Add Option to Command List
  #--------------------------------------------------------------------------
  def add_option_command
    add_command(Vocab::option, :option, true)
  end
  
end
