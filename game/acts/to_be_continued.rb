module Tarona
  # The act is shown when the player
  class ToBeContinued < TextAct
    def display_format
      tk.i18n['game/to_be_continued']
    end

    def next_act
      :to_be_continued
    end
  end
end
