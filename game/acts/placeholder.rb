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
    hex_size 15
  end
end
