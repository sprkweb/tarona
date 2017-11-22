module Tarona
  module Game
    module AI
      # Standard AI for entity.
      #
      # The entity must have `#interactions`, have tag `:movable` and
      # be {Tarona::Action::Workable}.
      # @see Tarona::Action::Entity#ai
      module Standard
        extend self

        # @return [Array] list where attacks are sorted: best are first.
        def attacks_priority
          ['lazer_rifle_shoot']
        end

        # @yield [found_entity]
        # @yieldreturn [TrueClass,FalseClass] whether entity complies your
        #   conditions.
        # @return [Tarona::Action::Entity, nil] nearest found entity
        #   which complies your conditions, or nil.
        def find_nearest_entity(entity, session)
          map, index = map_info session
          found = nil
          min_dist = Float::INFINITY
          index.each_key do |id|
            next if id == entity.id
            other_entity = Action::PlaceEntity.find map, index, id
            next unless other_entity && (!block_given? || yield(other_entity))
            dist = Action::PlaceEntity.distance index, entity, other_entity
            if dist < min_dist
              min_dist = dist
              found = other_entity
            end
          end
          found
        end

        # Choses best attack.
        # @param entity [Tarona::Action::Entity] attacker
        # @param enemy [Tarona::Action::Entity] (optional) target
        #   of the attack. If given, chose only applicable attacks.
        # @return id of chosen interaction or nil.
        def best_attack(entity, session, enemy = nil)
          best_attack = nil
          attacks_priority.each do |id|
            attack = entity.interactions[id]
            next if attack.nil?
            applicable = enemy.nil? || attack.applicable?(session, enemy)
            next unless applicable
            best_attack = id
            break
          end
          best_attack
        end

        # Moves `entity` to the `place`.
        #
        # Block is optional and is executed for each place of the movement
        # path, starting with the nearest to `entity` and ending with the
        # final point. It is needed if you want to stop entity whilst its
        # movement in certain conditions (e.g. energy is ended).
        # @param entity [Tarona::Action::Entity]
        # @param place [Array<Integer>]
        # @yield [cur_place, next_place, inf]
        # @yieldparam inf [Hash] result of the
        #   {Tarona::Action::Pathfinder::FindPath}
        # @yieldreturn [TrueClass,FalseClass] if true, the entity will be
        #   moved to the next place; if false, the movement will be stopped.
        # @return [Hash, FalseClass] false if the entity is not moved,
        #   otherwise hash with keys: `:final` (coords of final point) and
        #   `:path_inf` (result of the {Tarona::Action::Pathfinder::FindPath})
        def move_to(act, entity, session, place)
          map, index = map_info session
          return false unless entity.tags.include?(:movable)
          block = (block_given? ? Proc.new : nil)
          from, to, path_inf = final_move_point session, entity, place, block
          return false unless to
          update_pos map, index, entity, from, to
          act.io.happen :move, entity_id: entity.id, to: to
          { path_inf: path_inf, final: to }
        end

        # Moves `entity` in position from which it can attack `enemy`.
        # @param act [Tarona::Action]
        # @param entity [Tarona::Action::Entity] attacker
        # @param enemy [Tarona::Action::Entity] target of attack
        def go_on_offensive(act, entity, session, enemy)
          to = find_place_near enemy, entity, session
          wanted_attack = entity.interactions[best_attack(entity, session)]
          is_end = offensive_stop_solver entity, enemy, wanted_attack, session
          update_energy entity, move_to(act, entity, session, to, &is_end)
        end

        def call(act, entity, session)
          enemy = find_nearest_enemy entity, session
          return unless enemy && !entity.interactions.empty?
          attack = best_attack entity, session, enemy
          sleep 0.1
          if attack
            entity.interactions[attack].apply session, enemy, act.io
          else
            go_on_offensive act, entity, session, enemy
          end
        end

        private

        def offensive_stop_solver(attacker, enemy, wanted_attack, session)
          proc do |_, next_place, inf|
            if next_place
              next_move_cost = inf[:costs][next_place][:total]
              next_move_cost <= attacker.energy &&
                !wanted_attack.applicable?(session, enemy)
            else
              false
            end
          end
        end

        def find_place_near(enemy, entity, session)
          _, index, catalyst = map_info session
          ref_point = index[entity.id]
          enemy_places = Action::PlaceEntity.places_taken enemy, index[enemy.id]
          potential_targets = surrounding_places enemy_places, session
          to = nearest ref_point, potential_targets
          until catalyst.call(entity, to)
            to = nearest ref_point, surrounding_places([to], session)
          end
          to
        end

        def update_energy(entity, move_result)
          return false unless move_result
          final = move_result[:final]
          entity.tire move_result[:path_inf][:costs][final][:total]
        end

        def surrounding_places(area, session)
          map, = map_info session
          inner = area
          result = inner.inject([]) do |a, place|
            a + map.neighbors(*place)
          end
          result - inner
        end

        def nearest(from, array_to)
          array_to.min do |a, b|
            Action::Cartographer.distance(from, a) <=>
              Action::Cartographer.distance(from, b)
          end
        end

        # Where we want to be and where we can be is not always the same place.
        def final_move_point(session, entity, to, block)
          map, index, catalyst = map_info session
          from = index[entity.id]
          path_inf = get_path map, catalyst, entity, from, to
          return false unless path_inf[:found]
          final = to
          final = check_path(path_inf, &block) if block
          [from, final, path_inf]
        end

        def check_path(path_inf)
          path = path_inf[:path]
          final = path.last
          path.each_index do |i|
            unless yield path[i], path[i + 1], path_inf
              final = path[i]
              break
            end
          end
          final
        end

        def get_path(map, catalyst, entity, from, to)
          Action::Pathfinder::FindPath.call(
            map: map, entity: entity, catalyst: catalyst,
            from: from, to: to
          ).result
        end

        def update_pos(map, index, entity, from, to)
          Action::PlaceEntity.move map, entity, from, to
          index[entity.id] = to
        end

        def find_nearest_enemy(entity, session)
          # If the entity has no side, everybody is an friend.
          return nil unless entity.respond_to?(:side)
          find_nearest_entity entity, session do |e|
            e.respond_to?(:side) && e.side != entity.side && e.respond_to?(:hp)
          end
        end

        def map_info(session)
          [
            session[:act_inf][:landscape],
            session[:act_inf][:entities_index],
            session[:act_inf][:catalyst]
          ]
        end
      end
    end
  end
end
