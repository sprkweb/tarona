module Tarona
  # This class represents part of a game. It consists of text, like the
  # beginning of "Star Wars".
  #
  # To create it, you just need to set `subject` and {#next_act}.
  # You should not overwrite the {#process} method.
  class TextAct < Act
    act_type :text

    def process
      @io.on_first :read do
        happen :end, next_act
      end
    end

    # You should redefine it.
    # @return [Tarona::Act] next act. It will be started as soon as player
    #   decide to continue.
    def next_act
    end
  end
end
