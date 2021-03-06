module Tarona
  module Game
    # Command which regenerates energy for entities with tag `:regen_energy`
    # and attribute with the same name (it shows how much energy must
    # be regenerated).
    # Energy is regenerated for entity after its tick if the new tick is not
    # its too.
    # You must set the `:landscape`, `:entities_index`, `:tick_counter`
    # options.
    class RegenEnergy < Tardvig::Command
      private

      def process
        @tick_counter.on :tick_end do |event|
          id = @tick_counter.whose event[:num]
          entity = Action::PlaceEntity.find(@landscape, @entities_index, id)
          if regen?(entity)
            new_value = entity.energy + entity.regen_energy
            entity.energy = [entity.max_energy, new_value].min
          end
        end
      end

      def regen?(entity)
        entity.respond_to?(:energy) && entity.tags.include?(:regen_energy)
      end
    end
  end
end
