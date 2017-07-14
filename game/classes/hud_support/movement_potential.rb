module Tarona
  module Game
    class HudSupport
      # Sends information about movement potential of entity when
      # it is requested through `Tardvig::GameIO`
      #
      # It responds to the `movement_potential_request` event
      # with attributes: `entity_id` (Entity's identificator).
      #
      # It sends back the `movement_potential_show` with attributes:
      # `entity_id`, `from` (Entity's center coordiates), `reachable`.
      # `reachable` is similar to {Action::Pathfinder::FindReachable#result},
      # but hashes are converted to arrays.
      #
      # You must set attributes below using `Tardvig::Command` interface to
      # start this command.
      # @!attribute [r] act
      #   @return [Tarona::Game::StandardAction] current act.
      # @!attribute [r] session
      #   @return [#[]] information about current game state.
      # @see Tarona::PrManager
      class MovementPotential < Tarona::PrManager
        private

        def job_type
          :movement_potential
        end

        def job(msg)
          entity = get_entity msg[:entity_id]
          return unless movable_entity?(entity)
          from = @session[:act_inf][:entities_index][entity.id]
          reachable = formatted_potential(entity, from)
          @act.io.happen(
            :movement_potential_show,
            entity_id: entity.id, from: from, reachable: reachable
          )
        end

        def movable_entity?(entity)
          entity &&
            entity.respond_to?(:energy) &&
            entity.tags.include?(:movable) &&
            entity.tags.include?(:user_controlled)
        end

        def potential(entity, from)
          Action::Pathfinder::FindReachable.call(
            map: @session[:act_inf][:landscape],
            from: from,
            entity: entity,
            max_cost: entity.energy,
            catalyst: @act.rules.mobilize.catalyst
          )
        end

        def formatted_potential(entity, from)
          potential = potential(entity, from).result
          {
            costs: potential[:costs].to_a,
            places: potential[:places].to_a
          }
        end

        def get_entity(id)
          map = @session[:act_inf][:landscape]
          index = @session[:act_inf][:entities_index]
          Tarona::Action::PlaceEntity.find map, index, id
        end
      end
    end
  end
end
