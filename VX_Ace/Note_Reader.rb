##Exposing notes in the Game_Map
class Game_Map
  def note
    @map.note
  end
end
##Exposing notes in ItemBase which expose it for items, skills, and armor/weapons
class Scene_ItemBase < Scene_MenuBase
  def note
    @class.note
  end
end
#to acessenemy notes: #$game_troop.members[0].enemy.note
#to acessparty member notes: #$game_party.members[0].actor.note
#to acess class notes: #$game_party.members[0].class.note

module Note_Reader  
  #will return a hash of var names and values as strings
  #so the caller need to cast to the correct type since this
  #will not know if it should be a int, float, or string
  def self.get_varibles(source)
    vars = {}
    if source.respond_to?(:note)
      for scan_results in source.note.scan(/@(.*?)=(.*?);/)
        if scan_results.size >= 2
          #note: currenly blank key and value can be added
          #ideally this should not hurt since blank = ""
          vars[scan_results[0]] =scan_results[1]
        end
      end
    end
    return vars
  end
  
end
