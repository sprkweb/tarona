module Tarona
  class Action
    # Module with methods for easier calculations about landscape.
    module Cartographer
      extend self

      # @param a [Array<Integer>] start point, `[x, y]` coordinates
      # @param b [Array<Integer>] finish point, `[x, y]` coordinates
      # @return [Integer] number of hexes between given hexes.
      def distance(a, b)
        cube_distance offset_to_cube(a), offset_to_cube(b)
      end

      # Makes line betwen two points.
      # @param a [Array<Integer>] start point, `[x, y]` coordinates
      # @param b [Array<Integer>] finish point, `[x, y]` coordinates
      # @return [Array<Array<Integer>>] array with coordinates of each place
      #   of the line.
      def line(a, b)
        return [a] if a == b
        a = offset_to_cube a
        b = offset_to_cube b
        n = cube_distance a, b
        (0..n).each_with_object([]) do |i, results|
          cube_coords = cube_round cube_lerp(a, b, 1.0 / n * i)
          results << cube_to_offset(cube_coords)
        end
      end

      private

      def cube_round(cube)
        rx = cube[0].round
        ry = cube[1].round
        rz = cube[2].round
        x_diff = (rx - cube[0]).abs
        y_diff = (ry - cube[1]).abs
        z_diff = (rz - cube[2]).abs

        if (x_diff > y_diff) && (x_diff > z_diff)
          rx = -ry - rz
        elsif y_diff > z_diff
          ry = -rx - rz
        else
          rz = -rx - ry
        end
        [rx, ry, rz]
      end

      def cube_distance(a, b)
        ((a[0] - b[0]).abs + (a[1] - b[1]).abs + (a[2] - b[2]).abs) / 2
      end

      def lerp(a, b, t)
        a + (b - a) * t
      end

      def cube_lerp(a, b, t)
        [lerp(a[0], b[0], t), lerp(a[1], b[1], t), lerp(a[2], b[2], t)]
      end

      def cube_to_offset(cube)
        [cube[0] + (cube[2] - (cube[2] % 2)) / 2, cube[2]]
      end

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
