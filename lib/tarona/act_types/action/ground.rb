module Tarona
  class Action
    # Represents landscape and natural objects (ground, water, stones, etc.), or
    # floor, or any other object which has no interaction options, including
    # movement (of ground), dynamic creation or destroying.
    #
    # Takes one cell of landscape.
    class Ground
      attr_reader :id, :template

      # @param id [Symbol] identificator of your ground.
      # @param template [Symbol] id of SVG definition without `#` (hash) symbol.
      #   It will be used to show this object through `use` SVG element.
      #   See {Action.resources}.
      def initialize(id, template)
        @id = id
        @template = template
      end

      # @return content of the object expressed through common standard types.
      #   It is hash with those keys: `id`, `svg_id` (second is {#template}).
      def raw
        { id: @id, svg_id: @template }
      end
    end
  end
end
