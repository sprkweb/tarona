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
      Tarona::Action::Mobilize.call(
        io: @io,
        map: @tk.session[:act_inf][:landscape],
        entities_index: @tk.session[:act_inf][:entities_index],
        catalyst: proc { true }
      )
    end
  end
end
