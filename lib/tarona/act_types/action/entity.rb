module Tarona
  class Action
    # Represents any object which has interaction options: creatures, buildings,
    # etc. Unlike {Ground}, it can take several places of landscape, can be
    # moved, can have AI and is extendable in many ways.
    # @!attribute [r] hexes
    #   @return [Hash<Array<Array>>] what places does the entity takes
    #     relatively to itself. The hash must contain keys: `:even_row`, which
    #     is array of taken places when `y` coordinate of entity's center is
    #     even, `:odd_row` - when it is odd.
    #   @see http://www.redblobgames.com/grids/hexagons/#neighbors
    #   @see Landscape
    #   @example
    #       { even_row: [[0, 0], [-1, 1]], odd_row: [[0, 0], [0, 1]] }
    #       # when the entity's coordinates are [x, y] and y is event,
    #       # then it "stands" on both [x, y] and [(x - 1), (y + 1)] places.
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
        default_options = {
          hexes: { even_row: [[0, 0]], odd_row: [[0, 0]] }
        }
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
