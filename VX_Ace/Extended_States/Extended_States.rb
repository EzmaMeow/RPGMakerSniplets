#WARINGING: this override/replace a few functions since it be difficult to alias the logic in
#SO this should be the first in the load order and might not play nice to anything else that
#overide state based functinality

#this is an example of adding stacks to states. every reapply will increase the stack
#by one up to a defined max_stack and every natual removal (not removed by a feature) 
#will reduce the stack by 1 and removed fully when at 0 stacks.
#this is useful to add ways to extend the effect of a state, adding breakable shield
#where the stack size is the amount or health of the shield, or by special abilites
#that do more damage base on stack size.


#NOTE: the commented out block is an example of using Note_Reader to modify the state
#--------------------------------------------------------------------------
# * RPG::State
#--------------------------------------------------------------------------
#class RPG::State < RPG::BaseItem
  
#  def initial_stack
#    if @initial_stack == nil
#      @initial_stack = [Note_Reader.get_variable("initial_stack",self,1).to_i,0].max
#    end
#    return @initial_stack
#  end
  
#  def max_stack
#    if @max_stack == nil
#      @max_stack = [Note_Reader.get_variable("max_stack",self,1).to_i,0].max
#    end
#    return @max_stack
#  end  
#end


#--------------------------------------------------------------------------
# * Game_BattlerBase
#--------------------------------------------------------------------------
class Game_BattlerBase
  
  alias :old_clear_states_base_ext_states :clear_states
  alias :old_erase_state_base_ext_states :erase_state
  
  attr_reader   :state_stacks
  
  #--------------------------------------------------------------------------
  # * Clear State Information
  #--------------------------------------------------------------------------
  def clear_states
    old_clear_states_base_ext_states
    @state_stacks = {}
  end
  
  #--------------------------------------------------------------------------
  # * Erase States
  #--------------------------------------------------------------------------
  def erase_state(state_id)
    old_erase_state_base_ext_states(state_id)
    @state_stacks.delete(state_id)
  end
  
end

#--------------------------------------------------------------------------
# * Game_Battler
#--------------------------------------------------------------------------
class Game_Battler < Game_BattlerBase
  
  alias :old_remove_state_counts_battler_ext_states :remove_state
  
  #--------------------------------------------------------------------------
  # * Add State
  #--------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      if state?(state_id)
        state = $data_states[state_id]
        max_stack = 1
        if state.respond_to?(:max_stack)
          max_stack = state.max_stack
        end
        @state_stacks[state_id] = [@state_stacks[state_id] + 1,max_stack].min
        reset_state_counts(state_id)
      else
        add_new_state(state_id)
        initial_stack = 1
        if state.respond_to?(:initial_stack)
          initial_stack = state.initial_stack
        end
        @state_stacks[state_id] = initial_stack
        reset_state_counts(state_id)
      end
      @result.added_states.push(state_id).uniq!
    end
  end
  
  
  #--------------------------------------------------------------------------
  # * Remove State
  #--------------------------------------------------------------------------
  def remove_state(state_id, cleansed=false)
    if state?(state_id)
      state = $data_states[state_id]
      if cleansed
        old_remove_state_counts_battler_ext_states(state_id)
      else
        @state_stacks[state_id] -= 1
        if @state_stacks[state_id] <= 0
          old_remove_state_counts_battler_ext_states(state_id)
        else
          reset_state_counts(state_id)
          refresh
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * [Remove State] Effect
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    if rand < chance
      remove_state(effect.data_id,true)
      @result.success = true
    end
  end
end
