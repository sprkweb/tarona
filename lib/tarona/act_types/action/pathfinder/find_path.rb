module Tarona
  class Action
    module Pathfinder
      # A* algorithm for hexagonal map.
      # It finds the shortest path from point A to point B.
      # It expects that "movement cost" of place means "energy which is spent
      # to get to this place from any its neighbor".
      #
      # You need to set attributes {#map}, {#entity}, {#from}, {#to},
      # {#catalyst} using `#call` options (see `Tardvig::Command`).
      # @!attribute [r] map
      #   @return [Tarona::Action::Landscape] landscape on which path must
      #     be found.
      # @!attribute [r] entity
      #   @return [Tarona::Action::Movable] entity which will follow this path.
      #   @note It will not be moved whilst pathfinding, it is needed for
      #     finding obstacles and movement costs, which can be individual
      #     for each entity.
      # @!attribute [r] from
      #   @return [Array<Integer>] start point of the path, `[x, y]` coordinates
      # @!attribute [r] to
      #   @return [Array<Integer>] final point of the path, `[x, y]` coordinates
      # @!attribute [r] result
      #   @return [Hash] result of pathfinding.
      #     It contains `:found` key, which contains boolean:
      #     whether path is found or not.
      #     If path is found, it also contains:
      #
      #     - `:path` (Array) - the path itself. It is array containing
      #       sequential coordinates (in format of `[x, y]`) of each place
      #       of path from the first to the last
      #     - `:costs` (Hash) costs of movement to each place on the path
      #       from previous, where keys are `[x, y]` coordinates of places
      #       and values are hashes with two keys:
      #       - `:total` (Integer) cost of movement from start point of route
      #         to this place
      #       - `:last` (Integer) cost of movement from previous point of route
      #         to this place
      # @!attribute [r] catalyst
      #   @return [#call] object (proc, for example) which rules: whether the
      #     `entity` (1st argument given; {Tarona::Action::Entity}) can be
      #     placed `here` (2nd argument given; `[x, y]` coordinates).
      #     It must return `true` if it can be placed or `false` otherwise.
      #   @example Route from (0, 0) to (1, 3)
      #     {
      #       found: true,
      #       path: [[0, 0], [0, 1], [1, 2], [1, 3]],
      #       costs: {
      #         [0, 0] => { total: 0, last: 0 },
      #         [0, 1] => { total: 1, last: 1 },
      #         [1, 2] => { total: 2, last: 1 },
      #         [1, 3] => { total: 3, last: 1 }
      #       }
      #     }
      class FindPath < Tardvig::Command
        attr_reader :result

        # TODO: Refactor?

        def process
          init
          until @frontier.empty?
            current = @frontier.pop
            break if current == @to
            register_neighbors current
          end
          format_result
        end

        private

        def init
          @frontier = PriorityQueue.new
          @frontier[0] = @from
          @came_from = { @from => nil }
          @costs = { @from => { total: 0, last: 0 } }
        end

        def register_neighbors(current)
          @map.neighbors(*current).each do |neighbor|
            next unless register_node current, neighbor
            priority = @costs[neighbor][:total] + distance(@to, neighbor)
            @frontier[priority] = neighbor
          end
        end

        # Number of hexes between given hexes.
        def distance(a, b)
          ax, ay, az = offset_to_cube a
          bx, by, bz = offset_to_cube b
          ((ax - bx).abs + (ay - by).abs + (az - bz).abs) / 2
        end

        def offset_to_cube(coords)
          col, row = coords
          x = col - (row - (row & 1)) / 2
          z = row
          y = -x - z
          [x, y, z]
        end

        def format_result
          if @costs[@to]
            path = path_from_breadcrumbs
            costs = @costs.reject { |k, _| !path.include? k }
            @result = { found: true, costs: costs, path: path }
          else
            @result = { found: false }
          end
        end

        def path_from_breadcrumbs
          path = [@to]
          current = @to
          until path.last == @from
            current = @came_from[current]
            path << current
          end
          path.reverse
        end

        def register_node(previous, current)
          move_cost = get_move_cost previous, current
          total_cost = @costs[previous][:total] + move_cost
          another_path = @costs.key? current
          better_path = another_path && total_cost >= @costs[current][:total]
          obstacles = !@catalyst.call(@entity, current)
          return false if better_path || obstacles
          @costs[current] = { total: total_cost, last: move_cost }
          @came_from[current] = previous
          true
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
