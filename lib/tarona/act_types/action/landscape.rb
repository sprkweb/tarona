module Tarona
  class Action
    # This class represents the landscape of the action field.
    # The landscape consists of places (hexagons).
    # It contains information about every place on the field.
    class Landscape
      NEIGHBORS = {
        even_row: [[-1, -1], [-1, 0], [0, -1], [0, 1], [1, -1], [1, 0]],
        odd_row: [[-1, 0], [-1, 1], [0, -1], [0, 1], [1, 0], [1, 1]]
      }.freeze

      def initialize
        @landscape = {}
      end

      def add(*places)
        places.inject([]) do |result, coords|
          result + [add_place(coords)]
        end
      end

      def get(x, y)
        return unless @landscape[x].respond_to?(:[])
        @landscape[x][y]
      end

      def neighbors(x, y)
        row = (y.odd? ? :odd_row : :even_row)
        all_neighbors = NEIGHBORS[row].map { |a| [a[0] + x, a[1] + y] }
        clear_coords all_neighbors
      end

      private

      def add_place(coords)
        x, y = coords
        @landscape[x] = {} unless @landscape[x].respond_to?(:[])
        @landscape[x][y] = {}
      end

      def clear_coords(coords)
        coords.reject { |a| get(*a).nil? }
      end
    end
  end
end
