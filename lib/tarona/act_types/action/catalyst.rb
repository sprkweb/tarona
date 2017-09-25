module Tarona
  class Action
    # Object which rules whether an entity can be placed to a place.
    #
    # @see Tarona::Action::FindPath
    class Catalyst
      # Just a wrapper of a method from another module.
      # It is needed because PlaceEntity.method(:places_taken) can not be
      # saved inside YAML file.
      module PlacesTaken
        module_function

        def call(*args)
          PlaceEntity.places_taken(*args)
        end
      end

      # Initializes an instance of the catalyst for current act.
      # @param get_places [#call] any object with method `#call` which returns
      #   an array of coordinates (`[[x, y], ...]`) which are places
      #   taken by the `entity` (1st argument given; {Tarona::Action::Entity})
      #   when it is placed `here` (2nd argument given; `[x, y]` coordinates).
      # @param landscape [Tarona::Action::Landscape] landscape of this act.
      def initialize(get_places, landscape)
        @get_places = get_places
        @landscape = landscape
      end

      # It is the main method in this object. It checks the entity and the place
      # for compliance to all rules of placing.
      # @param entity [Tarona::Action::Entity] the entity itself
      # @param here [Array] coordinates `[x, y]` of the place
      # @return [TrueClass,FalseClass] whether the entity has passed all the
      #   filters and can be placed here.
      def call(entity, here)
        places_exist?(entity, here) && not_occupied?(entity, here)
      end

      # @param entity [Tarona::Action::Entity] the entity itself
      # @param here [Array] coordinates `[x, y]` of the place
      # @return [TrueClass,FalseClass] whether the landscape has got all places
      #   which are needed to place `entity` `here`?
      #   For example, it returns `false` if a part of `entity` is beyond
      #   the landscape when it is placed `here`.
      def places_exist?(entity, here)
        @get_places.call(entity, here).inject(true) do |exist, place|
          exist && positive_coords?(place) && !@landscape.get(*place).nil?
        end
      end

      # @param entity [Tarona::Action::Entity] entity which wants to get there
      # @param here [Array] coordinates `[x, y]` of the place
      # @return [TrueClass,FalseClass] true if there is no incompatible
      #   entity at the given place. Incompatible entity is an entity which
      #   can not stand at the same place with the given entity.
      def not_occupied?(entity, here)
        @get_places.call(entity, here).each do |coords|
          return false unless positive_coords?(coords)
          entities_here = (@landscape.get(*coords) || next)[:e] || next
          entities_here.each do |e|
            return false unless (e == entity) || compatible?(entity, e)
          end
        end
        true
      end

      private

      def positive_coords?(place)
        place[0] >= 0 && place[1] >= 0
      end

      def compatible?(_entity1, _entity2)
        # TODO: There are no entities which need to be compatible now, so
        # this method must be written as soon as they appear.
        false
      end
    end
  end
end
