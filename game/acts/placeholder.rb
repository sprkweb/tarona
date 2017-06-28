module Tarona
  # This is just placeholding act.
  class Placeholder < Action
    raw_sources = Dir.chdir(__dir__) { File.read('placeholder/map.yml') }
    sources = proc { YAML.load raw_sources }
    subject(
      landscape: proc { Landscape.new(sources.call['map']) },
      entities_index: proc { sources.call['entities'] }
    )
    resources << 'game/resources/ground.svg'
    resources << 'game/resources/entities.svg'
    resources << 'game/resources/style.svg'
    hex_size 15

    def set_listeners
      Game::StandardRules.call act: self, session: @tk.session
      Game::HudSupport.call act: self, session: @tk.session
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
