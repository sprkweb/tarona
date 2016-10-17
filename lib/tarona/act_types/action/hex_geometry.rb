module Tarona
  class Action
    # Some useful methods for calculating geometry properties of hexagons.
    module HexGeometry
      extend self

      # @param center [Array<(Integer, Integer)>] x and y coordinates of
      #   the hex center
      # @param size [Integer] distance from the center to the vertices of the
      #   hex
      # @return [String] SVG description of hexagon's border
      def get_line(center, size)
        points = get_points(center, size)
        result = "M #{point_to_s points.shift} "
        result += points.inject('') { |a, e| a + "L #{point_to_s e} " }
        result + 'Z'
      end

      # @param size [Integer] distance from the center to the vertices of the
      #   hex
      # @return [Integer] width of the hexagon
      def width(size)
        size * Math.sqrt(3)
      end

      # @param size [Integer] distance from the center to the vertices of the
      #   hex
      # @return [Integer] height of the hexagon
      def height(size)
        size * 2
      end

      # @param size [Integer] distance from the center to the vertices of the
      #   hex
      # @return [Integer] distance between centers of neighbouring vertical
      #   hexagons which are stacked into pattern
      # @example My first ASCII art
      #     .                 H                 H
      #     .              H     H           H     H
      #     .           H           H     H           H
      #     .        H                 H                 H
      #     .        H        A        H                 H
      #     .    --- H ------ *        H                 H
      #     .     ^  H                 H                 H
      #     .     |     H           H     H           H
      #     .   c |        H     H           H     H
      #     .     |           H                 H
      #     .     v           H        B        H
      #     .    ------------ H ------ *        H
      #     .                 H                 H
      #     .                    H           H
      #     .                       H     H
      #     .                          H
      #     A and B are points (centers of hexagons). c is vertical distance
      #     between them. c is returned.
      def vertical_space(size)
        size * 3 / 2
      end

      private

      def get_corner(center, i, size)
        x, y = center
        angle_rad = Math::PI * (2 * i + 1) / 6
        [x + size * Math.cos(angle_rad), y + size * Math.sin(angle_rad)]
      end

      def get_points(center, size)
        result = []
        6.times do |i|
          result << get_corner(center, i, size)
        end
        result
      end

      def point_to_s(point)
        x, y = point.map do |i|
          i = i.round(10)
          i = i.to_i if i.to_i == i
          i
        end
        "#{x} #{y}"
      end
    end
  end
end
