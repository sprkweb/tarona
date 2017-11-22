module Tarona
  module Game
    # Classes with preset properties for some type of entities.
    module Templates
      class AbstractSoldier < Tarona::Game::Fighter
        MAX_HP = 100

        def regen_energy() 300 end
        def max_energy() 600 end
        def max_hp() 100 end
        def speed() 1 end
        def move_speed() 16 end
        def ai() Tarona::Game::AI::Standard end

        def interactions
          @interactions ||= {
            'lazer_rifle_shoot' => Tarona::Game::Attack.new(
              name: 'attacks/lazer_rifle_shoot',
              distance: 5,
              owner: self,
              damage: 34,
              visual_effect: 'lazer_shot'
            )
          }
        end

        def tags
          [:mortal, :movable, :regen_energy]
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
        def max_energy() 1000 end
        def max_hp() 150 end
        def move_speed() 12 end
      end
    end
  end
end
