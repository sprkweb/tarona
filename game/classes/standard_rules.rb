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
    class StandardRules < Tardvig::Command
      attr_reader :tick_counter, :mobilize, :interactions_judge

      private

      def process
        @landscape = @session[:act_inf][:landscape]
        @entities_index = @session[:act_inf][:entities_index]

        init_tick_counter
        provide_movement
        provide_interactions
        provide_death
        provide_energy_regen
      end

      def init_tick_counter
        @tick_counter = TickCounter.new @session
        @tick_counter.candidates.concat activity_candidates
        @tick_counter.on :tick_start do |ev|
          id = @tick_counter.whose ev[:num]
          entity = find_entity id
          if entity.ai
            entity.ai.call entity, @session
            tick_counter.tick
          end
        end
      end

      def provide_movement
        catalyst = create_entities_catalyst
        @mobilize = Action::Mobilize.call(
          act: @act,
          map: @landscape,
          entities_index: @entities_index,
          catalyst: proc do |entity, to|
            catalyst.call(entity, to) && can_entity_act?(entity.id)
          end
        )
        @mobilize.on(:after_move) { @tick_counter.tick }
      end

      def provide_interactions
        @interactions_judge = InteractionsJudge.call(
          act: @act,
          session: @session,
          context_acceptable: proc do |entity|
            can_entity_act? entity.id
          end
        )
        @interactions_judge.on(:after_interact) { @tick_counter.tick }
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

      def create_entities_catalyst
        places_taken_method = Action::PlaceEntity.method(:places_taken)
        Action::Catalyst.new(places_taken_method, @landscape)
      end

      def can_entity_act?(entity_id)
        @tick_counter.whose(@session[:act_inf][:tick]) == entity_id
      end
    end
  end
end
