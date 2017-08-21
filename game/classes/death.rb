module Tarona
  module Game
    # Command which "kills" entities when their HPs are <= 0. The entities
    # must have tag `:mortal` to be killed.
    # You must set the `:landscape`, `:entities_index`, `:tick_counter`
    # and `:io` options.
    class Death < Tardvig::Command
      private

      def process
        @tick_counter.on :tick_start do
          check4dead
        end
      end

      def check4dead
        @entities_index.keys.each do |id|
          entity = Action::PlaceEntity.find(@landscape, @entities_index, id)
          if dead?(entity)
            remove_entity entity
            notify entity
          end
        end
      end

      def remove_entity(entity)
        coords = @entities_index.delete(entity.id)
        Action::PlaceEntity.remove @landscape, entity, coords
      end

      def notify(entity)
        @io.happen :remove, entity_id: entity.id
      end

      def dead?(entity)
        entity.respond_to?(:hp) && entity.tags.include?(:mortal) &&
          entity.hp <= 0
      end
    end
  end
end
