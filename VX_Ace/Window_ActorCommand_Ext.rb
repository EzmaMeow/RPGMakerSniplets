#--------------------------------------------------------------------------
# * Vocab
#   adding a default term
#--------------------------------------------------------------------------
module Vocab
  def self.wait;      "Wait";   end   # wait
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is for selecting an actor's action on the battle screen.
#==============================================================================

class Window_ActorCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    add_attack_command
    add_skill_commands
    add_guard_command
    add_rest_command
    add_item_command
    add_escape_command
  end
  #--------------------------------------------------------------------------
  # * Add Attack Command to List
  #--------------------------------------------------------------------------
  def add_rest_command
    add_command(Vocab::wait, :wait, true)
  end
  
  #--------------------------------------------------------------------------
  # * Add Attack Command to List
  #--------------------------------------------------------------------------
  def add_escape_command
    add_command(Vocab::escape, :escape, @actor.attack_usable?)
  end
end
