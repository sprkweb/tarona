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
    class InteractionsJudge < Tarona::PrManager
      include Tardvig::Events

      private

      def job_type
        :interaction
      end

      def job(msg)
        from, to = get_entities msg
        return unless to && from && from.respond_to?(:interactions)
        interaction = from.interactions[msg[:interaction_id]]
        return unless allowed?(from, to, interaction)
        interaction.apply @session, to
        happen :after_interact, from: from, to: to, interaction: interaction
      end

      def allowed?(from, to, interaction)
        from.tags.include?(:user_controlled) &&
          interaction.respond_to?(:applicable?) &&
          interaction.applicable?(@session, to)
      end

      def get_entities(msg)
        map = @session[:act_inf][:landscape]
        index = @session[:act_inf][:entities_index]
        [
          Tarona::Action::PlaceEntity.find(map, index, msg[:from_entity]),
          Tarona::Action::PlaceEntity.find(map, index, msg[:target])
        ]
      end
    end
  end
end
