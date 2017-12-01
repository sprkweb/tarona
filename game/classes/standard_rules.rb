module Tarona
  module Game
    # Command which combines and calls all the game's rules on top of Action
    # core: ticks, movement, interactions, etc.
    #
    # It runs {Action::Mobilize} and {InteractionsJudge}, so you can send their
    # incoming events through IO after you run this command.
    #
    # You must set the {#act} and {#session} attributes using
    # `Tardvig::Command` interface to start this command.
    # @!attribute [r] act
    #   @return [Tarona::Action] current act.
    # @!attribute [r] session
    #   @return [#[]] information about current game state.
    # @!attribute [r] action_loop
    #   @return [Thread] thread which runs ticks in a loop
    class StandardRules < Tardvig::Command
      attr_reader :tick_counter, :mobilize, :interactions_judge, :action_loop

      # Starts next tick properly. Use this instead of {TickCounter#tick}
      def next_tick
        raise 'Not player\'s tick' unless @action_loop.stop?
        @action_loop.run
      end

      private

      # TODO: Refactor
      def process
        @landscape = @session[:act_inf][:landscape]
        @entities_index = @session[:act_inf][:entities_index]

        init_tick_counter
        provide_movement
        provide_interactions

        # Listeners which are called before the end of the tick:
        provide_death
        provide_energy_regen
        # Listeners which are called after the start of the new tick, before
        # any actions:

        # The action itself:
        provide_ai_starter
      end

      def init_tick_counter
        @tick_counter = TickCounter.new @session
        @tick_counter.candidates.concat activity_candidates
        SkipTick.call act: @act, session: @session
      end

      def provide_ai_starter
        @action_loop = Thread.new do
          do_stop = false
          @act.on(:end) { do_stop = true }
          @tick_counter.tick { start_ai } until do_stop
        end
      end

      def start_ai
        id = @tick_counter.whose
        entity = find_entity id
        return unless entity
        if entity.ai
          entity.ai.call @act, entity, @session
        else
          Thread.stop
        end
      end

      def provide_movement
        catalyst = @session[:act_inf][:catalyst]
        @mobilize = Action::Mobilize.call(
          act: @act,
          map: @landscape,
          entities_index: @entities_index,
          catalyst: proc do |entity, to|
            can_entity_act?(entity.id) && catalyst.call(entity, to)
          end
        )
        @mobilize.on(:after_move) { next_tick }
      end

      def provide_interactions
        @interactions_judge = InteractionsJudge.call(
          act: @act,
          session: @session,
          context_acceptable: proc do |entity|
            can_entity_act? entity.id
          end
        )
        @interactions_judge.on(:after_interact) { next_tick }
      end

      def provide_death
        @death = Death.call(
          tick_counter: @tick_counter,
          landscape: @landscape,
          entities_index: @entities_index,
          io: @act.io
        )
      end

      def provide_energy_regen
        RegenEnergy.call(
          tick_counter: @tick_counter,
          landscape: @landscape,
          entities_index: @entities_index
        )
      end

      def activity_candidates
        ids = @entities_index.keys.select do |id|
          entity = find_entity id
          entity.ai || entity.tags.include?(:user_controlled)
        end
        ids.map(&method(:find_entity))
      end

      def find_entity(id)
        Action::PlaceEntity.find @landscape, @entities_index, id
      end

      def can_entity_act?(entity_id)
        @tick_counter.whose == entity_id
      end
    end
  end
end
