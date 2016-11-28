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
  #   * Landscape,Proc `landscape` - landscape object
  #     or proc object which returns landscape object for this act
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

    # It is list of files, their content will be loaded to the SVG `defs`
    # section. These files can include some predefined elements which can be
    # used as visualization of some objects (entities, ground).
    #
    # You should add some files to this variable. Note, paths must be relative
    # to the root directory of the project.
    # @return [Array] list of resources
    def self.resources
      @resources ||= []
    end

    def display_format
      c = self.class
      land = c.subject[:landscape]
      {
        hex_size: c.hex_size,
        # TODO: Store created landscape
        landscape: (land.respond_to?(:call) ? land.call : land).raw,
        dependencies: dependencies
      }
    end

    private

    def dependencies
      self.class.resources.inject('') { |a, e| a + File.read(e) }
    end
  end
end
