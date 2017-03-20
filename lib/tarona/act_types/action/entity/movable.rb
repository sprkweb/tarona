module Tarona
  class Action
    # @abstract It describes methods for entities which can be moved.
    module Movable
      # @param from [Tarona::Action::Ground] the movement starts here
      # @param to [Tarona::Action::Ground] the movement ends here. It is always
      #   a neighbor of the `from` argument.
      # @return [Integer] how much energy does the movement cost.
      def move_cost(from, to)
        raise NotImplementedError
      end
    end
  end
end
