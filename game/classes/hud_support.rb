module Tarona
  module Game
    # Command for {Tarona::Action} which makes server-side jobs for HUD when
    # it requests them.
    #
    # You must set attributes below using `Tardvig::Command` interface to
    # start this command.
    # @!attribute [r] act
    #   @return [Tarona::Action] current act.
    # @!attribute [r] session
    #   @return [#[]] information about current game state.
    class HudSupport < Tardvig::Command
      private

      def process
        parts = [Informer, EntityInfo]
        parts.each do |part|
          part.call act: @act, session: @session
        end
      end
    end
  end
end
