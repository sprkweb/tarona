module Tarona
  module Game
    # Live creature which can move, kill and be killed.
    # @!attribute [r] interactions
    #   @return [Hash<Interaction>] list of interactions which the entity can
    #     use. Keys are custom unique identificators.
    # @!attribute [r] max_hp
    #   @return [Integer] maximal possible number of HP for this entity
    #   @see #hp
    # @!attribute [rw] hp
    #   @return [Integer] "Health Points" (HP) is measure which represents
    #     overall state of entity.
    #     The more HP an entity has the stronger attacks it can survive.
    # @!attribute [r] name
    #   @return [String] name of the entity for display or its i18n key.
    class Fighter < Tarona::Action::Entity
      include Tarona::Action::Workable
      include Tarona::Action::Movable

      attr_reader :name, :interactions, :max_hp
      attr_accessor :hp

      # TODO
      # @see Tarona::Action::Movable
      def move_cost(from, to)
        1
      end

      def raw
        result = super
        if interactions
          result[:interactions] = interactions.each_with_object({}) do |a, b|
            b[a[0]] = a[1].raw
          end
        end
        result[:name] = name
        result
      end
    end
  end
end
