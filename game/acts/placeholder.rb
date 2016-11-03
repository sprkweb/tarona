module Tarona
  # This is just placeholding act.
  class Placeholder < Action
    sources = Dir.chdir(__dir__) { YAML.load File.read('placeholder/map.yml') }
    subject landscape: Landscape.new(sources['map'])
    hex_size 15
  end
end
