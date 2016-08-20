module Tarona
  # This class represents part of a game. It consists of text, like the
  # beginning of "Star Wars".
  class TextAct < Act
    act_type :text

    def process
      @io.on_first :read do
        happen :end, next_act
      end
    end

    private

    def next_act
    end
  end
end