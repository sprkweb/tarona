module Tarona
  module Game
    # @abstract An action which can be applied by one entity to another.
    # @!attribute [r] distance
    #   @return [Integer] maximal distance (in hexes) to which this interaction
    #     can be applied. Zero means there is no maximal distance. Default: 0.
    # @!attribute [r] owner
    #   @return [Tarona::Entity] entity which will apply this interaction.
    # @!attribute [r] name
    #   @return [String] name of the interaction.
    #   @example Translation for name
    #     if `game/i18n/en.yml` contents:
    #
    #       attacks:
    #         hit: Hit
    #
    #     then Interaction#name may be:
    #
    #       'attacks/hit'
    class Interaction
      attr_reader :distance, :owner, :name

      # @param options [Hash] you can initialize attributes of the object using
      #   this argument.
      #   `key => value` pairs, key is attribute you want to set.
      def initialize(options = {})
        default_options = {
          name: '',
          owner: nil,
          distance: 0
        }
        default_options.merge(options).each do |key, val|
          instance_variable_set "@#{key}".to_sym, val
        end
      end

      # Checks whether the interaction can be applied.
      # @abstract It checks distance only. You can redefine it if you want
      #   to check something else as well.
      # @param session [#[]] information about current game state.
      # @param entity [Tarona::Action::Entity] target of the interaction.
      # @return [TrueClass,FalseClass] whether the interaction can be applied
      def applicable?(session, entity)
        @distance.zero? ||
          (@distance >= Tarona::Action::Cartographer.distance(
            session[:act_inf][:entities_index][@owner.id],
            session[:act_inf][:entities_index][entity.id]
          ))
      end

      # @abstract raises `NotImplemented`
      # @param session [#[]] information about current game state.
      # @param entity [Tarona::Action::Entity] target of the interaction.
      # @return [TrueClass,FalseClass] whether the interaction is applied
      def apply(session, entity)
        raise NotImplementedError
      end

      # @return [Hash] content of the object expressed through common
      #   standard types.
      #   It is hash with those keys: `:name`, `:distance`
      def raw
        { name: @name, distance: @distance }
      end
    end
  end
end
