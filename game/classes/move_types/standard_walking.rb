module Tarona
  module Game
    module MoveType
      # Mixin for walking entities which calculates their movement cost.
      module StandardWalking
        include Action::Movable

        attr_reader :move_speed

        def move_cost(from, to)
          (costs_table[from.id] + costs_table[to.id]) * 72 / move_speed
        end

        # @return [Hash] pairs: ground type => cost
        def costs_table
          @costs_table ||= Hash.new(15).merge(
            'stone' => 15,
            'ground' => 17,
            'grass' => 19,
            'hill' => 25,
            'sand' => 21,
            'water' => 45,
            'abyss' => 65_000
          )
        end
      end
    end
  end
end
