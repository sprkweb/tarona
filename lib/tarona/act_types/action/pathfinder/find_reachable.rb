module Tarona
  class Action
    module Pathfinder
      # Find all reachable places from point A and shortest ways to them.
      #
      # You need to set attributes {#map}, {#from}, {#catalyst},
      # {#entity}, {#max_cost} (optional) using `#call` options
      # (see `Tardvig::Command`).
      # @!attribute [r] map
      #   @return [Tarona::Action::Landscape] landscape on which path must
      #     be found.
      # @!attribute [r] from
      #   @return [Array<Integer>] start point, `[x, y]` coordinates
      # @!attribute [r] entity
      #   @return [Tarona::Action::Movable] entity which will follow
      #     these paths.
      # @!attribute [r] max_cost
      #   @return [Integer] maximal available (energy) cost of paths,
      #     algorithm will not go further. It is needed when you, for example,
      #     want to find reachable paths for entity and you do not need
      #     unavailable places.
      # @!attribute [r] result
      #   @return [Hash] result, which consists of following keys:
      #
      #     - `:places` (Hash) contains reachable places as keys and neighboring
      #       places from which those places are reachable faster as values.
      #       Actually, if you want to find only reachable places, you can
      #       use `result[:places].keys`, values are needed only for finding
      #       full paths to individual places along the chain
      #       (see "code to reconstruct paths" from
      #       <http://www.redblobgames.com/pathfinding/a-star/introduction.html#breadth-first-search>).
      #     - `:costs` (Hash) contains reachable places as keys and costs to
      #       get to them as values.
      # @!attribute [r] catalyst
      #   @return [#call] object (proc, for example) which rules: whether the
      #     `entity` (1st argument given; {Tarona::Action::Entity}) can be
      #     placed `here` (2nd argument given; `[x, y]` coordinates).
      #     It must return `true` if it can be placed or `false` otherwise.
      #   @example
      #     # Start at (0, 0);
      #     # Map width is 2 hexes and height is 3 hexes;
      #     # Movement cost for all places is 1.
      #     {
      #       places: {
      #         [0, 0] => nil,    [1, 0] => [0, 0], [0, 1] => [0, 0],
      #         [1, 1] => [1, 0], [1, 2] => [0, 1], [0, 2] => [0, 1]
      #       },
      #       costs: {
      #         [0, 0] => 0,      [1, 0] => 1,      [0, 1] => 1,
      #         [1, 1] => 2,      [1, 2] => 2,      [0, 2] => 2
      #       }
      #     }
      class FindReachable < Tardvig::Command
        attr_reader :result

        # TODO: Refactor? Delete repetitions with FindPath?

        def process
          unless @map.get(*@from)
            @result = { places: {}, costs: {} }
            return
          end
          init
          until @frontier.empty?
            current = @frontier.pop
            @map.neighbors(*current).each do |neighbor|
              register_place current, neighbor
            end
          end
          format_result
        end

        private

        def init
          @frontier = [@from]
          @came_from = { @from => nil }
          @costs = { @from => 0 }
        end

        def format_result
          @result = { places: @came_from, costs: @costs }
        end

        def register_place(previous, current)
          move_cost = get_move_cost previous, current
          total_cost = @costs[previous] + move_cost
          is_obstacles = !@catalyst.call(@entity, current)
          too_far = (@max_cost ? total_cost > @max_cost : false)
          better_paths = better_paths? current, total_cost
          return if better_paths || too_far || is_obstacles
          @costs[current] = total_cost
          @came_from[current] = previous
          @frontier << current
        end

        def better_paths?(current, cost)
          @costs.key?(current) && cost >= @costs[current]
        end

        def get_move_cost(start, finish)
          start_obj = @map.get(*start)[:g]
          finish_obj = @map.get(*finish)[:g]
          @entity.move_cost start_obj, finish_obj
        end
      end
    end
  end
end
