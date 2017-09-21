module Tarona
  class Action
    # Represents any object which has interaction options: creatures, buildings,
    # etc. Unlike {Ground}, it can take several places of landscape, can be
    # moved, can have AI and is extendable in many ways.
    #
    # You can set attributes using {#initialize}.
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
    # @!attribute [r] ai
    #   @return [#call] artificial intelligence which controls the
    #     entity. It can be any object which has `#call(entity, session)` method
    #     and is serializable to YAML.
    #     Each time the entity "thinks" (its turn is come), the `#call` method
    #     of its AI must be called with arguments:
    #
    #     - `act`
    #     - `entity` - the entity itself;
    #     - `session` - see {Tarona::Action}.
    # @!attribute [r] tags
    #   @return [Array<Symbol>] list of custom words which describe the entity:
    #     its properties, membership in any groups, etc.
    #     It is useful for extensions, for example: combat properties,
    #     marking of allies...
    #   @example
    #     [:building, :elves] # Living house
    #     [:creature, :intelligent, :movable, :long_range, :elves] # Elf-archer
    class Entity
      attr_reader :id, :template, :hexes, :ai, :tags

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
          hexes: { even_row: [[0, 0]], odd_row: [[0, 0]] },
          tags: []
        }
        default_options.merge(options).each do |key, val|
          instance_variable_set "@#{key}".to_sym, val
        end
      end

      # @return content of the object expressed through common standard types.
      #   It is hash with those keys: `id`, `svg_id` (#template), `hexes`.
      def raw
        { id: @id, svg_id: @template, hexes: @hexes }
      end
    end
  end
end
