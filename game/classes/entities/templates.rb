module Tarona
  module Game
    # Classes with preset properties for some type of entities.
    module Templates
      class AbstractSoldier < Tarona::Game::Fighter
        MAX_HP = 100

        def regen_energy() 200 end
        def max_energy() 600 end
        def max_hp() 100 end
        def speed() 1 end
        def move_speed() 16 end

        def tags
          [:mortal]
        end

        def hexes
          {
            even_row: [[0, 0], [-1, 1], [0, 1]],
            odd_row: [[0, 0], [0, 1], [1, 1]]
          }
        end
      end

      class DidorianSoldier < AbstractSoldier
        TEMPLATE = 'soldier'.freeze

        def template() 'soldier' end
        def name() 'people/didorian_soldier' end
        def side() 'player' end
      end

      class RadlSoldier < AbstractSoldier
        TEMPLATE = 'soldier'.freeze
        MAX_HP = 150

        def template() 'enemy_soldier' end
        def name() 'people/radl_soldier' end
        def side() 'radls' end
        def max_energy() 800 end
        def max_hp() 150 end
        def move_speed() 12 end
      end
    end
  end
end
