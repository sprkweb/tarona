module Tarona
  # This is the introduction text at the begginning of the game
  class Introduction < TextAct
    def display_format
      tk.i18n['game/intro']
    end

    def next_act
      :pholder
    end
  end
end
