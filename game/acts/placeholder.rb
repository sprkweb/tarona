module Tarona
  # This is just placeholding act.
  class Placeholder < Action
    sources = Dir.chdir(__dir__) { YAML.load File.read('placeholder/map.yml') }
    subject landscape: proc { Landscape.new(sources['map']) }
    resources << 'game/resources/ground.svg'
    hex_size 15
  end
end
