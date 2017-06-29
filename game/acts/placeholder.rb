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
      landscape = @tk.session[:act_inf][:landscape]
      entities_index = @tk.session[:act_inf][:entities_index]
      @io.on :interaction_request do |msg|
        id = msg[:target]
        target = Action::PlaceEntity.find landscape, entities_index, id
        happen :end, :the_end if target.id == 'enemy_man' && target.hp <= 0
      end
    end
  end
end
