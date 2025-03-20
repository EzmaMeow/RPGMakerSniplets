#this is an example of force boarding or unboarding a vehicle
#for cases where one want to travel to a sea map, but is not
#a boat, ship, or airship at the time of triggering

class Game_Player < Game_Character
  #will relocate the vehicle to player
  #so may need to make sure the player is sent to
  #the correct location first
  def force_vehicle(type = :walk)
    if type == :walk
      @vehicle_getting_on = false 
      @vehicle_getting_off = true
    elsif type == :ship || type == :boat || type == :airship
      @vehicle_type = type
      @vehicle_getting_off = false  
      @vehicle_getting_on = true
    end
  end
end
