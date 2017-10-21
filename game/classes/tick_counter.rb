module Tarona
  module Game
    # Class which creates the system of ticks (turns).
    # Tick is a part of game time. One activity from one entity can be executed
    # per tick.
    # @!attribute [r] candidates
    #   @return [Array] list of entities which want to act. You can change it.
    class TickCounter
      include Tardvig::Events

      attr_reader :candidates

      # @param session [#[]] information about current game state.
      def initialize(session)
        @session = session
        @session[:act_inf][:tick] = 1 unless @session[:act_inf][:tick]
        @candidates = []
      end

      # Executes given closure for the current tick and starts a new one.
      # Triggers the `:tick_start` event for this object and passes arguments:
      # hash with keys: `:num` - number of the new tick.
      def tick
        yield if block_given?
        num = @session[:act_inf][:tick] + 1
        @session[:act_inf][:tick] = num
        happen :tick_start, num: num
      end

      # Decides which entity acts at the tick.
      # The entity is always from the {#candidates} list.
      # @param tick_num [Integer] number of the tick
      # @return [Object, nil] entity id
      def whose(tick_num)
        cycle = []
        candidates.each do |entity|
          next unless @session[:act_inf][:entities_index][entity.id]
          speed = (entity.respond_to?(:speed) ? entity.speed : 1)
          cycle.concat(Array.new(speed) { entity })
        end
        return nil if cycle.empty?
        cycle_start = tick_num / cycle.length * cycle.length + 1
        cycle[tick_num - cycle_start].id
      end
    end
  end
end
