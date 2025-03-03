
#Depends on Sp_Crafting

# * INJECTIONS  *

#--------------------------------------------------------------------------
# * Vocab
#--------------------------------------------------------------------------
module Vocab 
  def self.craft;      "Craft";   end   
end
#--------------------------------------------------------------------------
# * Scene_Menu
#--------------------------------------------------------------------------
class Scene_Menu < Scene_MenuBase
  alias :old_create_command_window_sp_crafting :create_command_window
  def create_command_window
    old_create_command_window_sp_crafting
    @command_window.set_handler(:craft,  method(:command_craft))
  end
  
  def command_craft
    SceneManager.call(Scene_Recipe)
  end
end

#--------------------------------------------------------------------------
# * Window_MenuCommand
#--------------------------------------------------------------------------
class Window_MenuCommand < Window_Command
  alias :old_add_original_commands_sp_crafting :add_original_commands
  def add_original_commands
    old_add_original_commands_sp_crafting
    add_craft_command
  end
  def add_craft_command
    add_command(Vocab::craft, :craft, true)
  end
end

# * CLASSES  *

#--------------------------------------------------------------------------
# * Window_Recipe_Command
#--------------------------------------------------------------------------
class Window_Recipe_Command < Window_Command
  
  def make_command_list
    add_commands
  end
  
  def add_commands
    for recipe in @recipes
      add_command(recipe.name, :activate, true, recipe)
    end
  end
  
  def initialize(recipes)
    @recipes = recipes
    super(0, 0)
    refresh
    activate
  end
end

#--------------------------------------------------------------------------
# * Scene_Recipe
#--------------------------------------------------------------------------
class Scene_Recipe < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @command_window = Window_Recipe_Command.new(Recipe_Handler.common_recipes)
    @display_window = Window_Selectable.new(
      @command_window.width, 0, Graphics.width-@command_window.width,
      Graphics.height
    )
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:activate,  method(:command_activate))
    @last_index = -1
  end
  
  def redraw
    @display_window.refresh
    draw_recipe(@command_window.current_ext,@command_window.index)
  end
  
  def command_activate
    recipe = @command_window.current_ext
    if recipe
      can_craft = true
      for result in recipe.results
        if result.create? == false
          can_craft = false
          break
        end
      end
      if can_craft
        for ingredient in recipe.ingredients
          if ingredient.use? == false
            can_craft = false
            break
          end
        end
      end
      if can_craft
        for ingredient in recipe.ingredients
          ingredient.use
        end
        for result in recipe.results
          result.create
        end
        redraw
      end
    end
    @command_window.activate
  end
  
  def draw_recipe(recipe,index = 0)
    rect = @command_window.item_rect(index)
    x = 0
    y = 0
    
    @display_window.draw_text(
      x, y, rect.width, rect.height, "Required:", 2
    )
    y += rect.height
    
    for slot in 0..recipe.ingredients.size-1
      ingredient = recipe.ingredient(slot)
      if ingredient
        amount = ingredient.amount
        owned = ingredient.amount_owned
        text = amount.to_s + " | " + owned.to_s
        draw_name(ingredient.name, ingredient.icon, x, y, rect.width, rect.height)
        x += rect.width
        @display_window.draw_text(
          x, y, rect.width, rect.height, text, 2
        )
        x=0
        y += rect.height
      end
    end
    y += rect.height
    @display_window.draw_text(
      x, y, rect.width, rect.height, "Creates:", 2
    )
    y += rect.height
    for slot in 0..recipe.results.size-1
      result = recipe.result(slot)
      if result
        amount = result.amount
        owned = result.amount_owned
        text = amount.to_s + " | " + owned.to_s
        draw_name(result.name, result.icon, x, y, rect.width, rect.height)
        x += rect.width
        @display_window.draw_text(
          x, y, rect.width, rect.height, text, 2
        )
        x=0
        y += rect.height
      end
    end
  end
  
  def draw_name(name, icon_index=0, x, y, width, height)
    @display_window.draw_icon(icon_index, x, y, true)
    @display_window.draw_text(x + 24, y, width, height, name)
  end
  
  def update
    super
    if @last_index != @command_window.index
      @last_index = @command_window.index
      redraw
    end
  end
  
end
