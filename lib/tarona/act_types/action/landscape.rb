module Tarona
  class Action
    # This class represents the landscape of the action field.
    # The landscape consists of places (hexagons).
    # It contains information about every place on the field.
    #
    # Coordinate system is "odd-r" (see
    # [there](http://www.redblobgames.com/grids/hexagons/#coordinates)).
    # Hexes are pointy topped.
    class Landscape
      NEIGHBORS = {
        even_row: [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, 0]],
        odd_row: [[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
      }.freeze

      # @param raw [Array<Array<Hash>>] matrix containing landscape places.
      #   The object will be created from it.
      def initialize(raw = nil)
        @landscape = raw || []
      end

      # Add places to the landscape. They are empty hashes by default.
      # @param places [Array<Integer>] places' coordinates (x and y).
      #   See example
      # @return [Array<Hash>] added places
      # @example Add places with coordinates A(1, 2) and B(1, 0)
      #   landscape.add [1, 2], [1, 0]
      def add(*places)
        places.inject([]) do |result, coords|
          result + [add_place(coords)]
        end
      end

      # @param x [Integer] x coordinate
      # @param y [Integer] y coordinate
      # @return [nil, Hash] place with given coordinates
      #   or `nil` if there is no such place.
      def get(x, y)
        return unless @landscape[x].respond_to?(:[])
        @landscape[x][y]
      end

      # @param (see #get)
      # @return [Array<Array<Integer>>] coordinates of the neighbors of the
      #   given place.
      #   Neighbors are hexagons which are placed around the given place (see
      #   class description about the coordinate system)
      def neighbors(x, y)
        return [] unless get(x, y)
        row = (y.odd? ? :odd_row : :even_row)
        all_neighbors = NEIGHBORS[row].map { |a| [a[0] + x, a[1] + y] }
        clear_coords all_neighbors
      end

      # @return content of the object expressed through common standard types.
      def raw
        @landscape.map do |cells|
          cells.map { |x| make_raw_place x }
        end
      end

      private

      def add_place(coords)
        x, y = coords
        @landscape[x] = [] unless @landscape[x].respond_to?(:[])
        @landscape[x][y] = {}
      end

      def clear_coords(coords)
        coords.reject { |a| get(*a).nil? || a[0] < 0 || a[1] < 0 }
      end

      def make_raw_place(place)
        place.each_with_object({}) do |property, raw_place|
          key, val = property
          raw_place[key] = (
            if val.class == Array
              val.map(&:raw)
            else
              val.raw
            end)
        end
      end
    end
  end
end
