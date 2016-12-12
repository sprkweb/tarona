module Tarona
  class Action
    # Represents any object which has interaction options: creatures, buildings,
    # etc. Unlike {Ground}, it can take several places of landscape, can be
    # moved, can have AI and is extendable in many ways.
    # @!attribute [r] hexes
    # FIXME: THIS WILL NOT WORK http://www.redblobgames.com/grids/hexagons/#neighbors
    #   @return [Array<Array>] what places does the entity takes
    #     relatively to itself
    #   @example
    #       [[0, 0], [-1, 1]]
    #       # when the entity's coordinates are [x, y], then it "stands"
    #       # on both [x, y] and [(x - 1), (y + 1)] places.
    class Entity
      attr_reader :id, :template, :hexes

      # @param id [Symbol] identificator of your entity.
      # @param template [Symbol] id of SVG definition without `#` (hash) symbol.
      #   It will be used to show this object through `use` SVG element.
      #   See {Action.resources}.
      # @param options [Hash] `key => value` pairs, key is attribute you want to
      #   set.
      def initialize(id, template, options = {})
        @id = id
        @template = template
        default_options = { hexes: [[0, 0]] }
        default_options.merge(options).each do |key, val|
          instance_variable_set "@#{key}".to_sym, val
        end
      end

      # @return content of the object expressed through common standard types.
      #   It is hash with those keys: `id`, `svg_id` (second is #template).
      def raw
        { id: @id, svg_id: @template }
      end
    end
  end
end
