module Tarona
  module Game
    # Command for {Tarona::Action} which allows to use
    # {Tarona::Game::Interaction} in it.
    #
    # It applies an interaction when it is requested through `io` event
    # `:interaction_request` with argument: `Hash` with keys
    # `from_entity` (id of the Entity which initiates the interaction),
    # `target` (id of the Entity which is target of the interaction),
    # `interaction_id` (Identificator of the interaction).
    #
    # It applies an interaction if its owner has the ':user_controlled' tag and
    # the interaction respond `true` to `#applicable?`.
    #
    # You must set attributes below using `Tardvig::Command` interface to
    # start this command.
    # @!attribute [r] act
    #   @return [Tarona::Action] current act.
    # @!attribute [r] session
    #   @return [#[]] information about current game state.
    class InteractionsJudge < Tardvig::Command
      private

      def process
        @act.io.on :interaction_request, &pr_manager
        @act.on :end do
          @act.io.remove_listener :interaction_request, pr_manager
        end
      end

      def pr_manager
        @pr_manager ||= proc do |msg|
          initiator = find_entity msg[:from_entity]
          target = find_entity msg[:target]
          if initiator && target && initiator.respond_to?(:interactions)
            interaction = initiator.interactions[msg[:interaction_id]]
            allowed = allowed? initiator, target, interaction
            interaction.apply @session, target if allowed
          end
        end
      end

      def allowed?(from, to, interaction)
        from.tags.include?(:user_controlled) &&
          interaction.respond_to?(:applicable?) &&
          interaction.applicable?(@session, to)
      end

      def find_entity(id)
        coords = @session[:act_inf][:entities_index][id]
        return nil unless coords
        place = @session[:act_inf][:landscape].get(*coords)
        return nil unless place && place[:e]
        place[:e].find { |x| x.id == id }
      end
    end
  end
end
