module Tarona
  # This is just placeholding act.
  class Placeholder < Game::StandardAction
    name :placeholder
    resources << 'game/resources/ground.svg'
    resources << 'game/resources/entities.svg'

    def process
      set_victory_conditions
    end

    def set_victory_conditions
      check_if_victory = proc do |msg|
        if msg[:entity_id] == 'enemy_man'
          happen :end, :the_end
          @io.remove_listener(:remove, &check_if_victory)
        end
      end
      @io.on(:remove, &check_if_victory)
    end
  end
end
