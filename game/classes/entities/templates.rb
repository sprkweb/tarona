module Tarona
  module Game
    # Classes with preset properties for some type of entities.
    module Templates
      class DidorianSoldier < Tarona::Game::Fighter
        def template() 'man' end
        def name() 'people/didorian_soldier' end
        def side() 'player' end
        def regen_energy() 200 end
        def max_energy() 600 end
        def max_hp() 100 end
        def speed() 1 end
        def move_speed() 16 end

        def tags
          []
        end

        def hexes
          {
            even_row: [[0, 0], [-1, 1], [0, 1]],
            odd_row: [[0, 0], [0, 1], [1, 1]]
          }
        end
      end
    end
  end
end
