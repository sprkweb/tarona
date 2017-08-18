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
      @io.on :remove do |msg|
        happen :end, :the_end if msg[:entity_id] == 'enemy_man'
      end
    end
  end
end
