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
  # @!attribute [r] acts
  #   @see Tarona::Doorman#new
  # @!attribute [r] first_act
  #   @see Tarona::Doorman#new
  # @!attribute [r] io
  #   @return an object which can be used as input/output. It will be passed to
  #     the acts.
  #   @see Tardvig::GameIO
  class Play < Tardvig::Command

    private

    def process
      @next_act = @acts[@first_act]
      until @next_act.nil?
        switch_act
        execute_act
      end
    end

    def execute_act
      blocker = new_blocker
      @current_act.on_first :end do |next_act|
        unblock(blocker)
        @next_act = @acts[next_act]
      end
      @current_act.call io: @io
      block_execution(blocker)
    end

    def switch_act
      @current_act = @next_act.new
      @next_act = nil
    end

    def new_blocker
      blocker = Thread.new { Thread.stop }
      sleep 0.01 while blocker.status != 'sleep'
      blocker
    end

    def unblock(blocker)
      blocker.run
    end

    def block_execution(blocker)
      blocker.join
    end
  end
end