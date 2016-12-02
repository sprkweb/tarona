module Tarona
  class Action
    # Module with methods for eathier placement and movement of entities
    # on landscape.
    module PlaceEntity
      module_function

      # Convert relative coordinates to absolute.
      # @param hexes [Array<Array>] array of relative coordinates: `[x, y]`
      # @param center [Array] place from which these coordinates are relative
      #   (`[x, y]`)
      # @return [Array<Array>] absolute coordinates.
      # @see Entity#hexes
      def abs_hexes(hexes, center)
        x, y = center
        hexes.map do |hex|
          [hex[0] + x, hex[1] + y]
        end
      end
    end
  end
end
