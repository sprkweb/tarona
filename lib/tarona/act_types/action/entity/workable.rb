module Tarona
  class Action
    # Mixin for entities which can do something, tire,
    # obey orders (of an player) or not.
    # @!attribute [rw] max_energy
    #   @return [Integer] maximal possible amount of energy
    # @!attribute [rw] energy
    #   @return [Integer] amount of energy which this entity has now.
    #     Energy is numeric property which shows ability of this entity to
    #     perform work. This mixin does not controls ways to spend or earn it,
    #     there are just tools for you to set this ways by yourself.
    #     You can, for, example, set a limit of available movement per turn for
    #     an entity using energy.
    #
    #     Default energy value is {#max_energy}.
    module Workable
      attr_accessor :user_controlled, :max_energy
      attr_writer :energy

      def energy
        @energy ||= @max_energy
      end

      # Remove some energy from the entity.
      # Energy is removed only if the entity have enough energy.
      # @param how_much [Integer,nil] how much action points should be removed.
      #   If `nil` is given, remove all energy.
      # @return [TrueClass,FalseClass] whether energy is removed or not.
      def tire(how_much = nil)
        if how_much.nil?
          @energy = 0
          true
        elsif energy < how_much
          false
        else
          @energy -= how_much
          true
        end
      end

      # Restore energy (action points) which is spent with the {#tire} method
      # @param how_much [Integer,nil] how much action points should be restored.
      #   If `nil` is given, restore all energy.
      # @return [Integer] how much energy does entity have now
      def relax(how_much = nil)
        if how_much.nil? || (energy + how_much > @max_energy)
          @energy = @max_energy
        else
          @energy += how_much
        end
        @energy
      end
    end

    # {Entity} with {Workable} mixin.
    class WorkableEntity < Entity
      include Workable
    end
  end
end
