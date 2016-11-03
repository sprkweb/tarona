module Tarona
  # Action is a main type of act. In this act players control the game course.
  # It consists of a map. Player controls things which belongs to him on the
  # map (these things on the map are called "entities").
  # Map consists of hexagons.
  #
  # To create an action act, you need to set:
  #
  # * {.hex_size}
  # * Hash `subject`. Keys:
  #   * Landscape `landscape`
  class Action < Act
    act_type :action

    # @overload hex_size(size)
    #   @param size [Integer] distance for center of hex to its vertices.
    #   @return [Integer] distance for center of hex to its vertices.
    # @overload hex_size()
    #   @return [Integer, nil] distance for center of hex to its vertices.
    def self.hex_size(size = nil)
      if size
        @hex_size = size
      else
        @hex_size
      end
    end

    def display_format
      {
        hex_size: self.class.hex_size,
        landscape: self.class.subject[:landscape].raw
      }
    end
  end
end
