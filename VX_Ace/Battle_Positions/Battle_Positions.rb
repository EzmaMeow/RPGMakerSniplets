#Requires Game_Battler :extra_damage_value
  # Window_ActorCommand :add_movement_commands
#as added functionality. Ext files of those should have it.

# * INJECTIONS  * 

#--------------------------------------------------------------------------
# * Vocab
#--------------------------------------------------------------------------
module Vocab
  def self.move_forward;   "Forward";   end
  def self.move_back;      "Back";   end
end

class Game_Battler < Game_BattlerBase
  alias :old_initialize_battler_battle_positions :initialize
  alias :old_extra_damage_value_battler_battle_positions :extra_damage_value
  
  attr_reader   :position
  
  def initialize
    old_initialize_battler_battle_positions
    @position = 0
  end

  def change_position(new_position = 0)
    @position = new_position
  end
  def move_back?
    !dead? && movable? && @position < 2
  end
  def move_forward?
    !dead? && movable? && @position > 0
  end
  
  def apply_position_effect(value,user,item)
    range = item.range if item.respond_to?(:range) else 4
    distance = @position + user.position #(melee: 0+0 = 0 range, mid =1, back=2) 
    penalty = 1.0/([distance - range + 1 ,1].max.to_f) 
    return (value * penalty).to_i
  end
  
  def extra_damage_value(value,user,item)
    new_value = value
    new_value = old_extra_damage_value_battler_battle_positions(new_value,user,item)
    new_value = apply_position_effect(new_value,user,item)
    return new_value
  end
end

class Game_Actor < Game_Battler
  
  alias :old_initialize_actor_battle_positions :initialize
  alias :old_on_battle_end_actor_battle_positions :on_battle_end
  
  attr_accessor  :formation_position
  
  def initialize(actor_id)
    old_initialize_actor_battle_positions(actor_id)
    @formation_position = 0
  end
  
  def on_battle_end
    old_on_battle_end_actor_battle_positions
    puts ""
    return if !respond_to?(:change_position)
    print " meow: "; print @position
    change_position(@formation_position)
    print " mew: "; print @position
  end
end

#--------------------------------------------------------------------------
# * Game_Unit
#-------------------------------------------------------------------------
class Game_Unit
  
  alias :old_initialize_unit_battle_positions :initialize
  
  attr_accessor  :min_position
  attr_accessor  :max_position     
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    old_initialize_unit_battle_positions
    @min_position = 0
    @max_position = 3
  end
  
  #move everyone forward
  def move_forward
    active_members = members
    if respond_to?(:battle_member)
      active_members = battle_member
    end
    for member in active_members
      print " test1 "
      return if !member.respond_to?(:position)
      print " test2 "
      next if member.dead? || !member.movable?
      print " test3 "
      min_position = @min_position
      if member.respond_to?(:min_position)
        print " testX "
        min_position = [member.min_position,@min_position].max
      end
      print " test4 "
      next if member.position <= min_position
      print " test5 "
      member.change_position(member.position-1)
    end
  end
  
  #move everyone back
  def move_backward
    active_members = members
    if respond_to?(:battle_member)
      active_members = battle_member
    end
    for member in active_members
      return if !member.respond_to?(:position)
      next if member.dead? || !member.movable?
      max_position = @max_position
      if member.respond_to?(:max_position)
        #we do not want to go past the group limit
        max_position = [member.max_position,@max_position].min
      end
      next if member.position >= max_position
      member.change_position(member.position+1)
    end
  end
  
  #return true if there a gap in the front row
  def advance?
    #min position can be a gap or front row fliers(if logic is added)
    min_position_count = 0
    active_members = members
    if respond_to?(:battle_member)
      active_members = battle_member
    end
    for member in active_members
      return false if !member.respond_to?(:position)
      #ignore dead, but not movable still counts
      next if member.dead?
      #will forward if there no one on front lines
      #if everyone at their min, then move forward will not
      #change anything, but this will force backrow to move ahead of
      #flyiers
      if member.position <= @min_position
        min_position_count += 1
      end
    end
    return true if min_position_count == 0
    return false
  end
  
end

#--------------------------------------------------------------------------
# * Window_ActorCommand
#-------------------------------------------------------------------------
class Window_ActorCommand < Window_Command
  alias :old_add_movement_commands_battle_positions :add_movement_commands
  
  def add_movement_commands
    add_move_forward_command
    add_move_back_command
    old_add_movement_commands_battle_positions
  end
  
  def add_move_forward_command
    add_command(Vocab::move_forward, :foward, @actor.move_forward?)
  end
  
  def add_move_back_command
    add_command(Vocab::move_back, :back, @actor.move_back?)
  end
  
end
#--------------------------------------------------------------------------
# * Scene_Battle
#-------------------------------------------------------------------------
class Scene_Battle < Scene_Base
  alias :old_create_actor_command_window_battle_positions :create_actor_command_window
  
  def create_actor_command_window
    old_create_actor_command_window_battle_positions
    @actor_command_window.set_handler(:back, method(:command_move_back))
    @actor_command_window.set_handler(:foward, method(:command_move_foward))
  end
  
  #--------------------------------------------------------------------------
  # * command_move_back
  #--------------------------------------------------------------------------
  def command_move_back
    actor = BattleManager.actor
    if actor
      actor.change_position(actor.position + 1)
    end
    next_command
  end
  
  #--------------------------------------------------------------------------
  # * command_move_foward
  #--------------------------------------------------------------------------
  def command_move_foward
    actor = BattleManager.actor
    if actor
      actor.change_position(actor.position - 1)
    end
    next_command
  end
  
end
