module Tarona
  class Action
    # Module with methods for easier calculations about landscape.
    module Cartographer
      extend self

      # @param a [Array<Integer>] start point, `[x, y]` coordinates
      # @param b [Array<Integer>] finish point, `[x, y]` coordinates
      # @return [Integer] number of hexes between given hexes.
      def distance(a, b)
        ax, ay, az = offset_to_cube a
        bx, by, bz = offset_to_cube b
        ((ax - bx).abs + (ay - by).abs + (az - bz).abs) / 2
      end

      private

      def offset_to_cube(coords)
        col, row = coords
        x = col - (row - (row & 1)) / 2
        z = row
        y = -x - z
        [x, y, z]
      end
    end
  end
end
