module Tarona
  module Game
    class HudSupport
      # Command which, when it is run, sends through IO various events with
      # information about server-side events for this act:
      #
      # - `:tick_start` event (see {TickCounter})
      #
      # You must set attributes below using `Tardvig::Command` interface to
      # start this command.
      # @!attribute [r] act
      #   @return [Tarona::Game::StandardAction] current act.
      # @!attribute [r] session
      #   @return [#[]] information about current game state.
      class Informer < Tardvig::Command
        private

        def process
          @act.rules.tick_counter.on :tick_start do |inf|
            @act.io.happen :tick_start, inf
          end
        end
      end
    end
  end
end
