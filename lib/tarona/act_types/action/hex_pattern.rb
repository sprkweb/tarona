module Tarona
  class Action
    # This module is responsible for calculating properties of a hexagonal
    # pattern.
    module HexPattern
      Hex = HexGeometry

      extend self

      # @param cols [Integer] number of columns in a pattern
      # @param hex_size [Integer] distance from the center to the vertices
      # @return [Integer] width of a pattern with given properties
      def width(cols, hex_size)
        ((cols + 0.5) * Hex.width(hex_size)).ceil
      end

      # @param rows [Integer] number of rows in a pattern
      # @param hex_size [Integer] distance from the center to the vertices
      # @return [Integer] height of a pattern with given properties
      def height(rows, hex_size)
        ((rows - 1) * Hex.vertical_space(hex_size) +
         Hex.height(hex_size)).ceil
      end

      # @param coords [Array<Integer>] x and y coordinates of the hexagon in
      #   a hexagonal grid
      # @param hex_size [Integer] distance from the center to the vertices
      # @return [Array<Integer>] x and y (pixels) coordinates of the hexagon
      def get_pos(coords, hex_size)
        col, row = coords
        x = Hex.width(hex_size) * (2 * col + row % 1 + 1) / 2
        y = Hex.vertical_space(hex_size) * row + Hex.height(hex_size) / 2
        [x, y].map(&shorten_int)
      end

      private

      def shorten_int
        proc do |i|
          i = i.round(10)
          i = i.to_i if i.to_i == i
          i
        end
      end
    end
  end
end
