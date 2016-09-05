module Tarona
  # This is the introduction text at the begginning of the game
  class Introduction < TextAct
    def display_format
      tk.i18n['game']['intro']
    end
  end
end