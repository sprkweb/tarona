module Tarona
  module Game
    # Action act type with some standard additions on top of it.
    #
    # It automatically loads the `subject` from `game/acts/<act_name>/map.yml`.
    # It sets default `hex_size` and SVG resources.
    # It also starts {StandardRules} and {HudSupport}.
    #
    # @!attribute [r] rules
    #   @return [Tarona::Game::StandardRules] instance of the StandardRules
    #     command
    class StandardAction < Action
      attr_reader :rules

      def self.inherited(subclass)
        sources_cache = nil
        sources = proc do
          sources_cache ||= File.read("game/acts/#{subclass.name}/map.yml")
          YAML.load(sources_cache)
        end
        subclass.subject(
          landscape: proc { Landscape.new(sources.call['map']) },
          entities_index: proc { sources.call['entities'] }
        )
        subclass.resources << 'game/resources/style.svg'
        subclass.hex_size 15
      end

      # @overload name(size)
      #   Sets the name of the act.
      #   @param value [String, Symbol] any unique name of the act.
      #   @return [String, Symbol] given value
      # @overload name()
      #   @return [String, Symbol, nil] any unique name of the act
      def self.name(value = nil)
        if value
          @name = value
        else
          @name
        end
      end

      def display_format
        result = super
        result[:tick] = @tk.session[:act_inf][:tick]
        result
      end

      protected

      def init_act
        super
        catalyst = create_catalyst @tk.session[:act_inf][:landscape]
        @tk.session[:act_inf][:catalyst] = catalyst
      end

      def set_listeners
        @rules = Game::StandardRules.call act: self, session: @tk.session
        Game::HudSupport.call act: self, session: @tk.session
      end

      private

      def create_catalyst(landscape)
        Action::Catalyst.new Action::Catalyst::PlacesTaken, landscape
      end
    end
  end
end
