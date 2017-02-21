module Tarona
  class Action
    # Command which gives player ability to move his entities
    #
    # It mobilizes only entities with tag `:movable` and attribute
    # `#user_controlled == true`
    # `:movable` entities must be {Workable}.
    #
    # It moves entities when it is requested through {#io} event `:move_request`
    # with argument: `Hash` with keys: `:entity_id` ({Entity#id}) and
    # `:to` ([x, y]).
    # Of course, it moves entity only if it has enough energy and path
    # is available.
    #
    # You must set attributes below using `Tardvig::Command` interface to
    # start this command.
    # @!attribute [r] act
    #   @return [Tarona::Action] entities will be mobilized for this act.
    # @!attribute [r] map
    #   @return [Tarona::Action::Landscape] landscape of the current action
    # @!attribute [r] entities_index
    #   @return [Hash] hash with entities' identificators as keys and their
    #     coordinates (see {Tarona::Action::PlaceEntity}) as values.
    # @!attribute [r] catalyst
    #   @return [#call] object (proc, for example) which rules: whether the
    #     `entity` (1st argument given; {Tarona::Action::Entity}) can be
    #     placed `here` (2nd argument given; `[x, y]` coordinates).
    #     It must return `true` if it can be placed or `false` otherwise.
    class Mobilize < Tardvig::Command
      private

      def process
        @act.io.on :move_request, &pr_manager
        @act.on :end do
          @act.io.remove_listener :move_request, pr_manager
        end
      end

      def entity_obj(there, id)
        place = @map.get(*there)
        return nil unless place && place[:e]
        @map.get(*there)[:e].find { |x| x.id == id }
      end

      def movable_by_player?(entity)
        entity.respond_to?(:user_controlled) && entity.user_controlled &&
          entity.tags.include?(:movable)
      end

      def move_it(entity, from, to, msg)
        path_data = get_path entity, from, to
        return false unless path_data[:found]
        total_move_cost = path_data[:costs][to][:total]
        if entity.tire(total_move_cost)
          update_pos entity, from, to
          @act.io.happen :move, msg
          true
        else
          false
        end
      end

      def update_pos(entity, from, to)
        PlaceEntity.move @map, entity, from, to
        @entities_index[entity.id] = to
      end

      def get_path(entity, from, to)
        Tarona::Action::Pathfinder::FindPath.call(
          map: @map, entity: entity, from: from, to: to, catalyst: @catalyst
        ).result
      end

      def pr_manager
        @pr_manager ||= proc do |msg|
          from = @entities_index[msg[:entity_id]]
          if from
            entity = entity_obj from, msg[:entity_id]
            move_it entity, from, msg[:to], msg if movable_by_player? entity
          end
        end
      end
    end
  end
end
