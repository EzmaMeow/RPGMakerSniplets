#This is an example on improving battle cursor memory. It should remeber positions 
#on the last inputs. It could be improved, but for now it is enough to make battles
#faster without autobattling.

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  alias :old_create_actor_command_window_cmemory :create_actor_command_window
  alias :old_on_actor_ok_cmemory :on_actor_ok
  alias :old_on_skill_ok_cmemory :on_skill_ok
  alias :old_on_enemy_ok_cmemory :on_enemy_ok
  alias :old_on_item_ok_cmemory :on_item_ok
  alias :old_next_command_cmemory :next_command
  alias :old_select_actor_selection_cmemory :select_actor_selection
  alias :old_select_enemy_selection_cmemory :select_enemy_selection
  alias :old_start_actor_command_selection_cmemory :start_actor_command_selection
  alias :old_command_skill_cmemory :command_skill
  alias :old_command_item_cmemory :command_item

  #--------------------------------------------------------------------------
  # * Create Actor Commands Window
  #--------------------------------------------------------------------------
  def create_actor_command_window
    #memory is a hash for storing last selection
    @memory = {}
    old_create_actor_command_window_cmemory
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
    old_next_command_cmemory
  end
  
  #--------------------------------------------------------------------------
  # * Actor [OK]
  #--------------------------------------------------------------------------
  def on_actor_ok
    add_memory(BattleManager.actor,4,@actor_window.index)
    old_on_actor_ok_cmemory
  end
  
  #--------------------------------------------------------------------------
  # * Enemy [OK]
  #--------------------------------------------------------------------------
  def on_enemy_ok
    if @enemy_window.enemy
      add_memory(BattleManager.actor,3,@enemy_window.enemy.index)
      old_on_enemy_ok_cmemory
    else
      @enemy_window.activate
    end
  end
  
  
  #--------------------------------------------------------------------------
  # * Skill [OK]
  #--------------------------------------------------------------------------
  def on_skill_ok
    add_memory(BattleManager.actor,1,@skill_window.item)
    old_on_skill_ok_cmemory
  end
  
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    add_memory(BattleManager.actor,2,@item_window.index)
    old_on_item_ok_cmemory
  end
  
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def select_actor_selection
    old_select_actor_selection_cmemory
    @actor_window.index = get_memory(BattleManager.actor, 4) 
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Selection
  #--------------------------------------------------------------------------
  def select_enemy_selection
    old_select_enemy_selection_cmemory
    @enemy_window.index = [get_memory(BattleManager.actor, 3),@enemy_window.item_max-1].min
  end
  
  #--------------------------------------------------------------------------
  # * Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    old_start_actor_command_selection_cmemory
    @actor_command_window.index = get_memory(BattleManager.actor, 0)
  end
  
  #--------------------------------------------------------------------------
  # * [Skill] Command
  #--------------------------------------------------------------------------
  def command_skill
    old_command_skill_cmemory
    if get_memory(BattleManager.actor, 1) == 0
      @skill_window.index  = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * [Item] Command
  #--------------------------------------------------------------------------
  def command_item
    old_command_item_cmemory
    @item_window.index = get_memory(BattleManager.actor, 2)
  end
  
end
