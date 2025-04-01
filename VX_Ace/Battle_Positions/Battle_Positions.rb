#Requires Game_Battler :extra_damage_value
  # Window_ActorCommand :add_movement_commands
#as added functionality. Ext files of those should have it.

class Battle_Positions
  #index is the wtype, value is the skill id to use as normal attack
  WTYPE_ATTACK_SKILLS =[]
end

# * INJECTIONS  * 

#--------------------------------------------------------------------------
# * Vocab
#--------------------------------------------------------------------------
module Vocab
  def self.move_forward;   "Forward";   end
  def self.move_back;      "Back";   end
end


#--------------------------------------------------------------------------
# * RPG::BaseItem
#   declaring them here so weapon can use them
#   but since weapons range is a bonus, best return 0 and have UsableItem
#   set the defaults for skills
#--------------------------------------------------------------------------
class RPG::BaseItem
  def range
    0
  end
  def min_range
    0
  end
  def max_range
    0
  end
end
#--------------------------------------------------------------------------
# * RPG::UsableItem
#   making it so that normal attack skills have melee range
#   as default
#--------------------------------------------------------------------------
class RPG::UsableItem < RPG::BaseItem
  def range
    if @range == nil
      @range = 4
      if @damage.element_id == -1
        @range = 0
      end
    end
    return @range
  end
  
  def min_range
    if @min_range == nil
      @min_range = 0
    end
    return @min_range
  end
  
  def max_range
    if @max_range == nil
      @max_range = 20
      if @damage.element_id == -1
        @max_range = 1
      end
    end
    return @max_range
  end
end
  
#--------------------------------------------------------------------------
# * Game_Battler
#--------------------------------------------------------------------------
class Game_Battler < Game_BattlerBase
  alias :old_initialize_battler_battle_positions :initialize
  alias :old_extra_damage_value_battler_battle_positions :extra_damage_value
  
  attr_reader   :position
  
  def initialize
    old_initialize_battler_battle_positions
    @position = 0
    @min_position = 0
    @max_position = 100
  end
  
  #allow weapons bonuses to effect normal attack skills
  def get_range_bonuses(user,item)
    bonuses = [0,0,0]
    if !user.respond_to?(:weapons)
      return bonuses
    end
    weapon = user.weapons[0]
    if weapon && item.damage.element_id == -1
      if weapon.respond_to?(:range); bonuses[0] = weapon.range; end
      if weapon.respond_to?(:min_range); bonuses[1] = weapon.min_range; end
      if weapon.respond_to?(:max_range); bonuses[2] = weapon.max_range; end
    end
    return bonuses
  end
  
  #check to see if the user and item can reach
  #could be used to check targer since math should allow it
  def reach?(user,item)
    bonuses = get_range_bonuses(user,item)
    range = 4 + bonuses[0]
    min_range = 0 + bonuses[1]
    max_range = 20 + bonuses[2]
    if item.respond_to?(:range); range = item.range + bonuses[0]; end
    if item.respond_to?(:min_range); min_range = item.min_range + bonuses[1]; end
    if item.respond_to?(:max_range); max_range = item.max_range + bonuses[2]; end
    distance = [(@position + user.position) - range,0].max
    #note: distance need to be 0 or greater, else min_range wont work at 0
    print [range,min_range,max_range,distance]
    if distance < min_range || distance > max_range
      return false
    end
    return true
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
    bonuses = get_range_bonuses(user,item)
    range = 4 + bonuses[0]
    if item.respond_to?(:range); range = item.range + bonuses[0]; end
    distance = (@position + user.position) - range 
    if !reach?(user,item)
      @result.missed = true
      return 0
    end
    penalty = 1.0/([distance + 1 ,1].max.to_f)
    if value * penalty == 0
      @result.missed = true
      return 0
    end
    return (value * penalty).to_i
  end
  
  def extra_damage_value(value,user,item)
    new_value = value
    new_value = old_extra_damage_value_battler_battle_positions(new_value,user,item)
    new_value = apply_position_effect(new_value,user,item)
    return new_value
  end
end

#--------------------------------------------------------------------------
# * Game_Actor
#-------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  alias :old_initialize_actor_battle_positions :initialize
  alias :old_on_battle_end_actor_battle_positions :on_battle_end
  alias :old_attack_skill_id_actor_battle_positions :attack_skill_id
  
  attr_accessor  :formation_position
  
  def initialize(actor_id)
    old_initialize_actor_battle_positions(actor_id)
    @formation_position = 0
  end
  
  def on_battle_end
    old_on_battle_end_actor_battle_positions
    return if !respond_to?(:change_position)
    change_position(@formation_position)
  end
  
  #can override normal attack skills here
  def attack_skill_id
    #NOTE: duel weilding may be odd to work with. will focus more on the 
    #first weapon. ideally they be one handed and use default attack
    #which should be melee. trying to duel weild for added range bonus
    #wont really work well since it hard to figure out what the second attack is
    wtype_id = 0
    if weapons[0]
      wtype_id = weapons[0].wtype_id 
    end 
    if Battle_Positions::WTYPE_ATTACK_SKILLS[wtype_id]
      return Battle_Positions::WTYPE_ATTACK_SKILLS[wtype_id]
    end
    return old_attack_skill_id_actor_battle_positions
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
      return if !member.respond_to?(:position)
      next if member.dead? || !member.movable?
      min_position = @min_position
      if member.respond_to?(:min_position)
        min_position = [member.min_position,@min_position].max
      end
      next if member.position <= min_position
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
    min_position_count = 0
    active_members = members
    if respond_to?(:battle_member)
      active_members = battle_member
    end
    for member in active_members
      return false if !member.respond_to?(:position)
      #ignore dead, but not movable still counts
      next if member.dead?
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
