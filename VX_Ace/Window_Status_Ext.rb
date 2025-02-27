#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  This window displays full status specs on the status screen.
#==============================================================================

class Window_Status < Window_Selectable

  alias old_initialize initialize
  alias old_draw_block3 draw_block3
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    @page = 0
    old_initialize(actor)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(:LEFT)
      @page -= 1
      if @page < 0; @page = 2; end
      refresh
    elsif Input.trigger?(:RIGHT)
      @page += 1
      if @page > 2; @page = 0; end
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Block 3
  #--------------------------------------------------------------------------
  def draw_block3(y)
    if @page == 0
      old_draw_block3(y)
    elsif @page == 1
      draw_xparams(32, y)
    else
      draw_sparams(32, y)
    end
  end
  
  #NOTE: The order of these are base on their index value. Extra stats
  #are added at the end. This is mostly to get it display in game, but 
  #could be handled better.
  #--------------------------------------------------------------------------
  # * Draw Xparams
  #--------------------------------------------------------------------------
  def draw_xparams(x, y)
    x_params = ["Hit","Evasion","Critical","Critical Evasion","Magic Evasion",
    "Magic Reflection","Counter Rate","Hp Regeneration", "Mp Regeneration",
    "Tp Regeneration"]
    y_offset = y
    x_offset = x
    lasy_index = 0
    for i in 0..x_params.size-1
      if i >= 6 
        x_offset = 288
        y_offset = y + line_height * (i-6)
      else
        y_offset = y + line_height * i
      end
      change_color(system_color)
      draw_text(x_offset, y_offset, 120, line_height, x_params[i])
      change_color(normal_color)
      param_as_percent = (@actor.xparam(i)*100).floor.to_s + "%"
      draw_text(x_offset + 120, y_offset, 36, line_height, param_as_percent, 2)
      last_index = i
    end
    #Draw crit damage if actor has it exposed
    if @actor.respond_to?(:crit_damage)
      last_index += 1
      y_offset = y + line_height * (last_index -6)
      x_offset = 288
      change_color(system_color)
      draw_text(x_offset, y_offset, 120, line_height, "Critical Damage")
      change_color(normal_color)
      param_as_percent = (@actor.crit_damage*100).floor.to_s + "%"
      draw_text(x_offset + 120, y_offset, 36, line_height, param_as_percent, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Sparams
  #--------------------------------------------------------------------------
    def draw_sparams(x, y)
    s_params = ["Target Rate","Guard Effect","Recovery Effect","Pharmacology",
    "Mp Cost","Tp Charge","Physical Damage","Magical Damage",
    "Floor Damage","Experience Rate"]
    y_offset = y
    x_offset = x
    lasy_index = 0
    for i in 0..s_params.size-1
      if i >= 6 
        x_offset = 288
        y_offset = y + line_height * (i-6)
      else
        y_offset = y + line_height * i
      end
      change_color(system_color)
      draw_text(x_offset, y_offset, 120, line_height, s_params[i])
      change_color(normal_color)
      param_as_percent = (@actor.sparam(i)*100).floor.to_s + "%"
      draw_text(x_offset + 120, y_offset, 36, line_height, param_as_percent, 2)
    end
  end
end
