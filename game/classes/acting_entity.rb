module Tarona
  module Game
    # Represents entity which can control itself and do some actions.
    class ActingEntity < Tarona::Action::Entity
      include Tarona::Action::Workable

      # @see Tarona::Action::Movable
      def move_cost(from, to)
        1
      end
    end
  end
end
