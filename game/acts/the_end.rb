module Tarona
  # This is the "The End" text at the end of the game.
  class TheEnd < TextAct
    def display_format
      tk.i18n['game/the_end']
    end

    def next_act
      :the_end
    end
  end
end
