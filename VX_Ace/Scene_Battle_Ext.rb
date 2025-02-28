#depends on Window_ActorCommand_Ext

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  alias :old_create_actor_command_window :create_actor_command_window
  alias :old_on_actor_ok :on_actor_ok
  alias :old_on_skill_ok :on_skill_ok
  alias :old_on_enemy_ok :on_enemy_ok
  alias :old_on_item_ok :on_item_ok
  alias :old_next_command :next_command
  alias :old_select_actor_selection :select_actor_selection
  alias :old_select_enemy_selection :select_enemy_selection
  alias :old_start_actor_command_selection :start_actor_command_selection
  alias :old_command_skill :command_skill
  alias :old_command_item :command_item

  #--------------------------------------------------------------------------
  # * Create Actor Commands Window
  #--------------------------------------------------------------------------
  def create_actor_command_window
    #memory is a hash for storing last selection
    @memory = {}
    old_create_actor_command_window
    #below is used with Window_ActorCommand_Ext
    @actor_command_window.set_handler(:wait, method(:command_wait))
    @actor_command_window.set_handler(:escape, method(:command_escape))
  end
  
  #--------------------------------------------------------------------------
  # * command_wait
  #--------------------------------------------------------------------------
  def command_wait
    BattleManager.actor.input.set_skill(7)
    next_command
  end
  
  #--------------------------------------------------------------------------
  # * add memory
  #--------------------------------------------------------------------------
  #[command,skill,item,enemy,ally]
  def add_memory(actor, id, value)
    if @memory[actor] == nil
      @memory[actor] = []
    end
    @memory[actor][id] = value
  end
  
  #--------------------------------------------------------------------------
  # * get memory
  #--------------------------------------------------------------------------
  def get_memory(actor, id)
    if $game_system.respond_to?(:remember_cursor)
      if !$game_system.remember_cursor; return 0; end
    end
    if @memory[actor] == nil
      return 0
    end
    if @memory[actor][id] == nil
      return 0
    end
    return @memory[actor][id]
  end
  
  #--------------------------------------------------------------------------
  # * To Next Command Input
  #--------------------------------------------------------------------------
  def next_command
    add_memory(BattleManager.actor,0,@actor_command_window.index)
    old_next_command
  end
  
  #--------------------------------------------------------------------------
  # * Actor [OK]
  #--------------------------------------------------------------------------
  def on_actor_ok
    add_memory(BattleManager.actor,4,@actor_window.index)
    old_on_actor_ok
  end
  
  #--------------------------------------------------------------------------
  # * Enemy [OK]
  #--------------------------------------------------------------------------
  def on_enemy_ok
    add_memory(BattleManager.actor,3,@enemy_window.index)
    old_on_enemy_ok
  end
  
  #--------------------------------------------------------------------------
  # * Skill [OK]
  #--------------------------------------------------------------------------
  def on_skill_ok
    add_memory(BattleManager.actor,1,@skill_window.index)
    old_on_skill_ok
  end
  
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    add_memory(BattleManager.actor,2,@item_window.index)
    old_on_item_ok
  end
  
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def select_actor_selection
    old_select_actor_selection 
    @actor_window.index = get_memory(BattleManager.actor, 4)
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Selection
  #--------------------------------------------------------------------------
  def select_enemy_selection
    old_select_enemy_selection
    @enemy_window.index = get_memory(BattleManager.actor, 3)
  end
  
  #--------------------------------------------------------------------------
  # * Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    old_start_actor_command_selection
    @actor_command_window.index = get_memory(BattleManager.actor, 0)
  end
  
  #--------------------------------------------------------------------------
  # * [Skill] Command
  #--------------------------------------------------------------------------
  def command_skill
    old_command_skill
    if get_memory(BattleManager.actor, 1) == 0
      @skill_window.index  = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * [Item] Command
  #--------------------------------------------------------------------------
  def command_item
    old_command_item
    @item_window.index = get_memory(BattleManager.actor, 2)
  end
  
end
