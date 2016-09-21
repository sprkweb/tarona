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
  # @!macro [new] run_acts_attrs
  #   @!attribute [r] acts
  #     @return [Hash] hash containing your acts as values and their
  #       identificators as keys.
  #   @!attribute [r] first_act
  #     @return [Object] identificator of the act which must be executed 
  #       first.
  #   @!attribute [r] io
  #     @return an object which can be used as input/output. 
  #       It will be passed to the acts.
  #     @see Tardvig::GameIO
  #   @!attribute [r] tk
  #     @return [Toolkit] your toolkit
  #     @see Tardvig::Toolkit
  class Play < Tardvig::Command
    attr_reader :thread

    private

    def process
      RunActs.call(
        acts: @acts,
        first_act: @first_act,
        io: @io,
        tk: @tk)
    end
  end
end