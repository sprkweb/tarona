module Tarona
  # The act is shown when the player is a looser.
  class GameOver < TextAct
    def display_format
      tk.i18n['game/game_over']
    end

    def next_act
      :game_over
    end
  end
end
