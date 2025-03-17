#This should be one of the first below ▼ Materials due to it overriding some functions
#This gives all vocabs a function for terms allowing any to be change 
#It also add a example of a localiztion object. 

#It currently design to hold all or sets of langauges, but it may be possible to load it from
#file and keep one langauge per Localization object. The Localization check language in it self
#so the overall structure could be change to work with a single language. 

#I belive changing langauge at runtime should update it as long as there a translation loaded
#but this have yet to be tested. I should find time to make an example translation
#object or extention to the class that provides all the terms in the default project


# * CLASSES  * 
#==============================================================================
# ** Localization
#==============================================================================
class Localization
  attr_accessor :strings
  attr_accessor :terms
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    @strings = {}
    @terms = {}
    if !$game_language
      $game_language = "eng"
    end
  end
  
  #--------------------------------------------------------------------------
  # * get string
  #--------------------------------------------------------------------------
  def get_string(key)
    language = $game_language || "eng"
    if self.respond_to?(key)
      return self.send(key)
    end
    if @strings[key]
      return @strings[key][language]
    end
    return nil
  end
  
  #--------------------------------------------------------------------------
  # * get term
  #--------------------------------------------------------------------------
  def get_term(key,index=0)
    language = $game_language || "eng"
    if self.respond_to?(key)
      temp_terms = self.send(key)
      return temp_terms[index]
    end
    if @terms[key]
      temp_terms = @terms[key][language]
      if temp_terms
        return temp_terms[index]
      end
    end
    return nil
  end
  
  #example of def. will return a string. language is check in the function
  #This allow more control in scripts of what is return, but wont be easy 
  #to load data unless added to do such
  def test_string
    case $game_language
    when "eng"
      return "A term string"
    end
    return nil
  end
  
  #terms are arrays of strings, so this need to return an array
  #I won't nil check this, so try to return [] for nil terms
  #or use @terms instead.
  def test_term
    case $game_language
    when "eng"
      return ["Term1","Term2","Term3"]
    end
    return []
  end
end

# * OVERRIDES  * 

#==============================================================================
# ** Vocab
#==============================================================================

module Vocab
  #--------------------------------------------------------------------------
  # * Initialize Module
  #--------------------------------------------------------------------------
  def self.init
    @localization = Localization.new()
  end
  
  #--------------------------------------------------------------------------
  # * get localization object
  #   contains the current loaded translation texts
  #--------------------------------------------------------------------------
  def self.localization
    return @localization
  end
  
  #--------------------------------------------------------------------------
  # * get_localize_string
  #--------------------------------------------------------------------------
  def self.get_localize_string(key, default = "")
    if @localization
      fetched_string = @localization.get_string(key)
      if fetched_string
        return fetched_string
      end
    end
    return default
  end

  #--------------------------------------------------------------------------
  # * get_localize_term
  #--------------------------------------------------------------------------
  def self.get_localize_term(key, index=0, default = "")
    if @localization
      fetch_term = @localization.get_term(key,index)
      if fetch_term 
        return fetch_term 
      end
    end
    return default
  end
  
  # Shop Screen
  def self.shop_buy
    get_localize_string(:shop_buy,ShopBuy)
  end
  def self.shop_sell
    get_localize_string(:shop_sell,ShopSell)
  end
  def self.shop_cancel
    get_localize_string(:shop_cancel,ShopCancel)
  end
  def self.possession
    get_localize_string(:possession,Possession)
  end

  # Status Screen
  def self.exp_total
    get_localize_string(:exp_total,ExpTotal)
  end
  def self.exp_next
    get_localize_string(:exp_next,ExpNext)
  end

  # Save/Load Screen
  def self.save_message
    get_localize_string(:save_message,SaveMessage)
  end
  def self.load_message
    get_localize_string(:load_message,LoadMessage)
  end
  def self.file
    get_localize_string(:file,File)
  end

  # Display when there are multiple members
  def self.party_name
    get_localize_string(:party_name,PartyName)
  end

  # Basic Battle Messages
  def self.emerge
    get_localize_string(:emerge,Emerge)
  end
  def self.preemptive 
    get_localize_string(:preemptive,Preemptive)
  end
  def self.surprise
    get_localize_string(:surprise,Surprise)
  end
  def self.escape_start
    get_localize_string(:escape_start,EscapeStart)
  end
  def self.escape_failure
    get_localize_string(:escape_failure,EscapeFailure)
  end

  # Battle Ending Messages
  def self.victory
    get_localize_string(:victory,Victory)
  end
  def self.defeat
    get_localize_string(:defeat,Defeat)
  end
  def self.obtain_exp
    get_localize_string(:obtain_exp,ObtainExp)
  end
  def self.obtain_gold
    get_localize_string(:obtain_gold,ObtainGold)
  end
  def self.obtain_item
    get_localize_string(:obtain_item,ObtainItem)
  end
  def self.level_up
    get_localize_string(:level_up,LevelUp)
  end
  def self.obtain_skill
    get_localize_string(:obtain_skill,ObtainSkill)
  end
  

  # Use Item
  def self.use_item 
    get_localize_string(:use_item,UseItem)
  end

  # Critical Hit
  def self.critical_to_enemy
    get_localize_string(:critical_to_enemy,CriticalToEnemy)
  end
  def self.critical_to_actor 
    get_localize_string(:critical_to_actor,CriticalToActor)
  end

  # Results for Actions on Actors
  def self.actor_damage 
    get_localize_string(:actor_damage,ActorDamage)
  end
  def self.actor_recovery 
    get_localize_string(:actor_recovery,ActorRecovery)
  end
  def self.actor_gain 
    get_localize_string(:actor_gain,ActorGain)
  end
  def self.actor_loss 
    get_localize_string(:actor_loss,ActorLoss)
  end
  def self.actor_drain
    get_localize_string(:actor_drain,ActorDrain)
  end
  def self.actor_no_damage 
    get_localize_string(:actor_no_damage,ActorNoDamage)
  end
  def self.actor_no_hit 
    get_localize_string(:actor_no_hit,ActorNoHit)
  end

  # Results for Actions on Enemies
  def self.enemy_damage 
    get_localize_string(:enemy_damage,EnemyDamage)
  end
  def self.enemy_recovery 
    get_localize_string(:enemy_recovery,EnemyRecovery)
  end
  def self.enemy_gain 
    get_localize_string(:enemy_gain,EnemyGain)
  end
  def self.enemy_loss 
    get_localize_string(:enemy_loss,EnemyLoss)
  end
  def self.enemy_drain 
    get_localize_string(:enemy_drain,EnemyDrain)
  end
  def self.enemy_no_damage 
    get_localize_string(:enemy_no_damage,EnemyNoDamage)
  end
  def self.enemy_no_hit 
    get_localize_string(:enemy_no_hit,EnemyNoHit )
  end

  # Evasion/Reflection
  def self.evasion 
    get_localize_string(:evasion,Evasion)
  end
  def self.magic_evasion 
    get_localize_string(:magic_evasion,MagicEvasion)
  end
  def self.magic_reflection 
    get_localize_string(:magic_reflection,MagicReflection)
  end
  def self.counter_attack 
    get_localize_string(:counter_attack,CounterAttack)
  end
  def self.substitute 
    get_localize_string(:substitute,Substitute)
  end

  # Buff/Debuff
  def self.buff_add 
    get_localize_string(:buff_add,BuffAdd)
  end
  def self.debuff_add
    get_localize_string(:debuff_add,DebuffAdd)
  end
  def self.buff_remove
    get_localize_string(:buff_remove,BuffRemove)
  end

  # Skill or Item Had No Effect
  def self.action_failure 
    get_localize_string(:action_failure,ActionFailure)
  end

  # Error Message
  def self.player_pos_error
    get_localize_string(:player_pos_error,PlayerPosError)
  end
  def self.event_overflow
    get_localize_string(:event_overflow,EventOverflow)
  end

  # Basic Status
  def self.basic(basic_id)
    get_localize_term(:basic, basic_id, $data_system.terms.basic[basic_id])
  end

  # Parameters
  def self.param(param_id)
    get_localize_term(:param, param_id, $data_system.terms.params[param_id])
  end

  # Equip Type
  def self.etype(etype_id)
    get_localize_term(:etype, etype_id, $data_system.terms.etypes[etype_id])
  end

  # Commands
  def self.command(command_id)
    get_localize_term(:command, command_id, $data_system.terms.commands[command_id])
  end

  # Currency Unit
  def self.currency_unit
    get_localize_string(:currency_unit,$data_system.currency_unit)
  end

  #--------------------------------------------------------------------------
  def self.level
    get_localize_string(:level,basic(0))
  end 
  def self.level_a
    get_localize_string(:level_a,basic(1))
  end 
  def self.hp
    get_localize_string(:hp,basic(2))
  end
  def self.hp_a
    get_localize_string(:hp_a,basic(3))
  end 
  def self.mp
    get_localize_string(:mp,basic(4))
  end
  def self.mp_a
    get_localize_string(:mp_a,basic(5))
  end
  def self.tp
    get_localize_string(:tp,basic(6))
  end
  def self.tp_a
    get_localize_string(:tp_a,basic(7))
  end
  def self.fight
    get_localize_string(:fight,command(0))
  end
  def self.escape
    get_localize_string(:escape,command(1))
  end
  def self.attack
    get_localize_string(:attack,command(2))
  end
  def self.guard
    get_localize_string(:guard,command(3))
  end
  def self.item
    get_localize_string(:item,command(4))
  end
  def self.skill
    get_localize_string(:skill,command(5))
  end
  def self.equip
    get_localize_string(:equip,command(6))
  end
  def self.status
    get_localize_string(:status,command(7))
  end
  def self.formation
    get_localize_string(:formation,command(8))
  end
  def self.save
    get_localize_string(:save,command(9))
  end
  def self.game_end
    get_localize_string(:end_game,command(10))
  end
  def self.weapon
    get_localize_string(:weapon,command(12))
  end
  def self.armor
    get_localize_string(:armor,command(13))
  end
  def self.key_item
    get_localize_string(:key_item,command(14))
  end
  def self.equip2
    get_localize_string(:equip2,command(15))
  end
  def self.optimize
    get_localize_string(:optimize,command(16))
  end
  def self.clear
    get_localize_string(:clear,command(17))
  end
  def self.new_game
    get_localize_string(:new_game,command(18))
  end
  def self.continue
    get_localize_string(:continue,command(19))
  end
  def self.shutdown
    get_localize_string(:shutdown,command(20))
  end
  def self.to_title
    get_localize_string(:to_title,command(21))
  end
  def self.cancel
    get_localize_string(:cancel,command(22))
  end
  #--------------------------------------------------------------------------
end

#==============================================================================
# ** DataManager
#==============================================================================
module DataManager
  class<<self
    alias :old_init_vocab_overhaul :init
  end
  #--------------------------------------------------------------------------
  # * Initialize Module
  #--------------------------------------------------------------------------
  def self.init
    load_localization
    old_init_vocab_overhaul
  end
  
  def self.load_localization
    Vocab.init
  end
  
  #--------------------------------------------------------------------------
  # * Check Player Start Location Existence
  #--------------------------------------------------------------------------
  def self.check_player_location
    if $data_system.start_map_id == 0
      msgbox(Vocab.player_pos_error)
      exit
    end
  end
  
end

#==============================================================================
# ** BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # * Battle Start
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab.emerge, name))
    end
    if @preemptive
      $game_message.add(sprintf(Vocab.preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab.surprise, $game_party.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab.victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab.escape_start, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      process_abort
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab.escape_failure)
      $game_party.clear_actions
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # * Defeat Processing
  #--------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab.defeat, $game_party.name))
    wait_for_message
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Display EXP Earned
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab.obtain_exp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # * Gold Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_gold
    if $game_troop.gold_total > 0
      text = sprintf(Vocab.obtain_gold, $game_troop.gold_total)
      $game_message.add('\.' + text)
      $game_party.gain_gold($game_troop.gold_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(Vocab.obtain_item, item.name))
    end
    wait_for_message
  end
end

#==============================================================================
# ** Game_Actor 
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Show Level Up Message
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    $game_message.add(sprintf(Vocab.level_up, @name, Vocab::level, @level))
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab.obtain_skill, skill.name))
    end
  end
end

#==============================================================================
# ** Game_ActionResult
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Get Text for HP Damage
  #--------------------------------------------------------------------------
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab.actor_drain : Vocab.enemy_drain
      sprintf(fmt, @battler.name, Vocab::hp, @hp_drain)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab.actor_damage : Vocab.enemy_damage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab.actor_recovery : Vocab.enemy_recovery
      sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
    else
      fmt = @battler.actor? ? Vocab.actor_no_damage : Vocab.enemy_no_damage
      sprintf(fmt, @battler.name)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text for MP Damage
  #--------------------------------------------------------------------------
  def mp_damage_text
    if @mp_drain > 0
      fmt = @battler.actor? ? Vocab.actor_drain : Vocab.enemy_drain
      sprintf(fmt, @battler.name, Vocab::mp, @mp_drain)
    elsif @mp_damage > 0
      fmt = @battler.actor? ? Vocab.actor_loss : Vocab.enemy_loss
      sprintf(fmt, @battler.name, Vocab::mp, @mp_damage)
    elsif @mp_damage < 0
      fmt = @battler.actor? ? Vocab.actor_recovery : Vocab.enemy_recovery
      sprintf(fmt, @battler.name, Vocab::mp, -@mp_damage)
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text for TP Damage
  #--------------------------------------------------------------------------
  def tp_damage_text
    if @tp_damage > 0
      fmt = @battler.actor? ? Vocab.actor_loss : Vocab.enemy_loss
      sprintf(fmt, @battler.name, Vocab::tp, @tp_damage)
    elsif @tp_damage < 0
      fmt = @battler.actor? ? Vocab.actor_gain : Vocab.enemy_gain
      sprintf(fmt, @battler.name, Vocab::tp, -@tp_damage)
    else
      ""
    end
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Get Party Name
  #--------------------------------------------------------------------------
  def name
    return ""           if battle_members.size == 0
    return leader.name  if battle_members.size == 1
    return sprintf(Vocab.party_name, leader.name)
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Check for Overflow
  #    Under normal usage, the depth will not exceed 100. Since recursive
  #    event calls are likely to result in an infinite loop, the depth is
  #    cut off at 100 and an error results.
  #--------------------------------------------------------------------------
  def check_overflow
    if @depth >= 100
      msgbox(Vocab.event_overflow)
      exit
    end
  end
end

#==============================================================================
# ** Window_ShopCommand
#==============================================================================

class Window_ShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab.shop_buy,    :buy)
    add_command(Vocab.shop_sell,   :sell,   !@purchase_only)
    add_command(Vocab.shop_cancel, :cancel)
  end
end 

#==============================================================================
# ** Window_ShopStatus
#==============================================================================
class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Draw Quantity Possessed
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab.possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
end

#==============================================================================
# ** Window_Status
#==============================================================================
class Window_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # * Draw Experience Information
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.exp
    s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = sprintf(Vocab.exp_next, Vocab.level)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 180, line_height, Vocab.exp_total)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y + line_height * 1, 180, line_height, s1, 2)
    draw_text(x, y + line_height * 3, 180, line_height, s2, 2)
  end
end

#==============================================================================
# ** Window_SaveFile
#==============================================================================
class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    name = Vocab.file + " #{@file_index + 1}"
    draw_text(4, 0, 200, line_height, name)
    @name_width = text_size(name).width
    draw_party_characters(152, 58)
    draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Display Skill/Item Use
  #--------------------------------------------------------------------------
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      add_text(subject.name + item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      add_text(sprintf(Vocab.use_item, subject.name, item.name))
    end
  end
  #--------------------------------------------------------------------------
  # * Display Counterattack
  #--------------------------------------------------------------------------
  def display_counter(target, item)
    Sound.play_evasion
    add_text(sprintf(Vocab.counter_attack, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Reflection
  #--------------------------------------------------------------------------
  def display_reflection(target, item)
    Sound.play_reflection
    add_text(sprintf(Vocab.magic_reflection, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Substitute
  #--------------------------------------------------------------------------
  def display_substitute(substitute, target)
    add_text(sprintf(Vocab.substitute, substitute.name, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Failure
  #--------------------------------------------------------------------------
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      add_text(sprintf(Vocab.action_failure, target.name))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Critical Hit
  #--------------------------------------------------------------------------
  def display_critical(target, item)
    if target.result.critical
      text = target.actor? ? Vocab.critical_to_actor : Vocab.critical_to_enemy
      add_text(text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Miss
  #--------------------------------------------------------------------------
  def display_miss(target, item)
    if !item || item.physical?
      fmt = target.actor? ? Vocab.actor_no_hit : Vocab.enemy_no_hit
      Sound.play_miss
    else
      fmt = Vocab.action_failure
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # * Display Evasion
  #--------------------------------------------------------------------------
  def display_evasion(target, item)
    if !item || item.physical?
      fmt = Vocab.evasion
      Sound.play_evasion
    else
      fmt = Vocab.magic_evasion
      Sound.play_magic_evasion
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # * Display Buff/Debuff
  #--------------------------------------------------------------------------
  def display_changed_buffs(target)
    display_buffs(target, target.result.added_buffs, Vocab.buff_add)
    display_buffs(target, target.result.added_debuffs, Vocab.debuff_add)
    display_buffs(target, target.result.removed_buffs, Vocab.buff_remove)
  end
end

#==============================================================================
# ** Scene_Load
#==============================================================================
class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # * Get Help Window Text
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab.load_message
  end
end

#==============================================================================
# ** Scene_Save
#==============================================================================
class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # * Get Help Window Text
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab.save_message
  end
end
