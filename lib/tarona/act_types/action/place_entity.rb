module Tarona
  class Action
    # Module with methods for eathier placement and movement of entities
    # on landscape.
    # @note **"Coordinates of entity"** means array `[x, y]` with integer
    #   coordinates of its central point. Central point is a place with
    #   relative (to the entity) coordinates: `[0, 0]`.
    module PlaceEntity
      module_function

      # Convert relative coordinates to absolute.
      # @param hexes [Array<Array>] array of relative coordinates: `[x, y]`
      # @param center [Array] place from which these coordinates are relative
      #   (`[x, y]`)
      # @return [Array<Array>] absolute coordinates.
      # @see Entity#hexes
      def abs_hexes(hexes, center)
        x, y = center
        hexes.map do |hex|
          [hex[0] + x, hex[1] + y]
        end
      end

      # @param entity [Entity] entity object
      # @param center [Array] coordinates of entity
      # @return [Array<Array>] places which the entity takes
      #   when it is placed here
      # @see Entity#hexes
      def places_taken(entity, center)
        parity = (center[1].even? ? :even_row : :odd_row)
        abs_hexes entity.hexes[parity], center
      end

      # Adds entity to the given place of the landscape.
      # @param landscape [Landscape] container of places.
      # @param entity [Entity] entity which you want to add to landscape.
      # @param here [Array] coordinates of the place you want to add entity to.
      # @return entity
      def add(landscape, entity, here)
        places_taken(entity, here).each do |hex|
          place_inf = landscape.get(*hex)
          place_inf[:e] ||= []
          place_inf[:e] << entity
        end
        entity
      end

      # Deletes entity from the landscape.
      # @param landscape [Landscape] container of places.
      # @param from [Array] coordinates of the entity.
      # @param entity [Entity] entity which you want to remove from landscape.
      def remove(landscape, entity, from)
        places_taken(entity, from).each do |hex|
          place_inf = landscape.get(*hex)
          place_inf[:e].delete entity
          place_inf.delete :e if place_inf[:e].empty?
        end
        entity
      end

      # Moves entity to another place on the landscape.
      # @param landscape [Landscape] container of places.
      # @param entity [Entity] entity which you want to move.
      # @param from [Array] coordinates of the entity's center place
      # @param to [Array] coordinates of the place you want to move entity to.
      # @return entity
      def move(landscape, entity, from, to)
        remove landscape, entity, from
        add landscape, entity, to
      end
    end
  end
end
