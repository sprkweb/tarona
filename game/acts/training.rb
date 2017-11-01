module Tarona
  # Training act after the interaction.
  class Training < Game::StandardAction
    name :training
    resources << 'game/resources/ground.svg'
    resources << 'game/resources/entities.svg'
    resources << 'game/resources/mirok.svg'

    def process
    end
  end
end
