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
  #   * Proc `landscape` - proc which builds landscape object for this act
  #   * Proc `entities_index` - proc which builds index of entities.
  #     Format: `{ entity.id => [x, y] }` where x and y are coordinates.
  #
  # Given toolkit must contain attributes `i18n` and `session` with
  # hashes as their values.
  # Some information about action will be stored under the `:act_inf` key of
  # session:
  #
  # - `:landscape` - instance of {Tarona::Action::Landscape} for this Action.
  # - `:entities_index` - see `.subject[:entities_index]` above.
  #
  # The i18n must be a hash with translations of the code phrases.
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

    # @return [Hash] hash containing keys: `:hex_size`, `:landscape`
    #   (value is {Landscape#raw}), `:entities_index`, `:i18n`
    #   and `:dependencies`.
    #   Dependencies are content of {.resources}.
    def display_format
      c = self.class
      {
        hex_size: c.hex_size,
        landscape: @tk.session[:act_inf][:landscape].raw,
        entities_index: @tk.session[:act_inf][:entities_index],
        i18n: @tk.i18n,
        dependencies: dependencies
      }
    end

    # You can redefine this method in order to set needed listeners.
    # It is called after initialization of session, but before the action.
    def set_listeners
    end

    private

    def init_act
      c = self.class
      @tk.session[:act_inf] = {
        landscape: c.subject[:landscape].call,
        entities_index: c.subject[:entities_index].call
      }
    end

    def first_run?
      @tk.session[:act_inf] == {}
    end

    def execute
      init_act if first_run?
      set_listeners
      super
    end

    def dependencies
      self.class.resources.inject('') { |a, e| a + File.read(e) }
    end
  end
end
