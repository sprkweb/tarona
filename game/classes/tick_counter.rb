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
        @session[:act_inf][:tick] ||= 1
        @session[:act_inf][:ticks_hist] ||= [:nobody]
        @candidates = []
      end

      # Executes given closure for the current tick and starts a new one.
      # Triggers the `:tick_start` event for this object and passes arguments:
      # hash with keys: `:num` - number of the new tick.
      def tick
        yield if block_given?
        happen :tick_end, num: @session[:act_inf][:tick]
        num = @session[:act_inf][:tick] + 1
        @session[:act_inf][:tick] = num
        happen :tick_start, num: num
      end

      # Decides which entity acts at the tick.
      # The entity is always from the {#candidates} list.
      # @param tick_num [Integer, nil] number of the tick
      #   (optional, default: current)
      # @return [Object, nil] entity id
      # @raise [RuntimeError] with message "Invalid history" if you request
      #   a future tick which is uncertain now,
      #   or message "No candidates".
      def whose(tick_num = nil)
        hist = @session[:act_inf][:ticks_hist]
        tick_num ||= @session[:act_inf][:tick]
        raise 'Invalid history' unless hist[tick_num - 1]
        unless hist[tick_num]
          cycle = generate_cycle
          raise 'No candidates' if cycle.empty?
          hist.concat cycle
        end
        hist[tick_num]
      end

      private

      def generate_cycle
        cycle = []
        candidates.each do |entity|
          next unless @session[:act_inf][:entities_index][entity.id]
          speed = (entity.respond_to?(:speed) ? entity.speed : 1)
          cycle.concat(Array.new(speed) { entity.id })
        end
        cycle
      end
    end
  end
end
