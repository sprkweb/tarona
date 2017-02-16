module Tarona
  class Action
    # Object which rules whether an entity can be placed to a place.
    #
    # @see Tarona::Action::FindPath
    class Catalyst
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
        places_exist?(entity, here)
      end

      # @param entity [Tarona::Action::Entity] the entity itself
      # @param here [Array] coordinates `[x, y]` of the place
      # @return [TrueClass,FalseClass] whether the landscape has got all places
      #   which are needed to place `entity` `here`?
      #   For example, it returns `false` if a part of `entity` is beyond
      #   the landscape when it is placed `here`.
      def places_exist?(entity, here)
        @get_places.call(entity, here).inject(true) do |exist, place|
          natural_nums = place[0] >= 0 && place[1] >= 0
          exist && natural_nums && !@landscape.get(*place).nil?
        end
      end
    end
  end
end
