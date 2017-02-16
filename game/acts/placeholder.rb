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
    hex_size 15

    def set_listeners
      landscape = @tk.session[:act_inf][:landscape]
      places_taken = Action::PlaceEntity.method(:places_taken)
      Action::Mobilize.call(
        io: @io,
        map: landscape,
        entities_index: @tk.session[:act_inf][:entities_index],
        catalyst: Action::Catalyst.new(places_taken, landscape)
      )
    end
  end
end
