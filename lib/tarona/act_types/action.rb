module Tarona
  # Action is a main type of act. In this act players control the game course.
  # It consists of a map. Player controls things which belongs to him on the
  # map (these things on the map are called "entities").
  class Action < Act
    act_type :action
  end
end
