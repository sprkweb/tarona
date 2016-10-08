module Tarona
  # This class represents a bundle of objects (including acts, io, etc) that
  # is dedicated to one player. It constitutes game process of the individual
  # player.
  #
  # @example Define attributes
  #   class MyIO < Tardvig::GameIO
  #     ...
  #   end
  #
  #   class MyAct < Tarona::Act
  #     ...
  #   end
  #
  #   acts = { main: MyAct }
  #   play = Tarona::Play.new io: MyIO.new, acts: acts, first_act: :main
  #
  # @!attribute [r] acts
  #   @return [Hash] hash containing your acts as values and their
  #     identificators as keys.
  # @!attribute [r] first_act
  #   @return [Object] identificator of the act which must be executed
  #     first.
  # @!attribute [r] io
  #   @return an object which can be used as input/output.
  #     It will be passed to the acts.
  #   @see Tardvig::GameIO
  # @!attribute [r] tk
  #   @return [Class] your toolkit class
  #   @see Tardvig::Toolkit
  # @!attribute [r] tk_instance
  #   @return [Tardvig::Toolkit] instance of your toolkit class. You does not
  #     need to pass it as an option. It will be created inside this play.
  class Play < Tardvig::Command
    attr_reader :thread

    private

    def process
      prepare
      RunActs.call(
        acts: @acts,
        first_act: @first_act,
        act_params: { io: @io, tk: @tk_instance })
    end
    
    def prepare
      @tk_instance = @tk.new
    end
  end
end