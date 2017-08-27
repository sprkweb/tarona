module Tarona
  module Game
    # Command which skips current tick (starts next) when player requests this
    # via `:skip_tick_request` event on `io`.
    # Entity, which acts at the moment, must have tag `:user_controlled`.
    #
    # You must set the `:session`, `:tick_counter` and `:act` options.
    class SkipTick < Tarona::PrManager
      private

      def job_type
        :skip_tick
      end

      def job(_)
        act_inf = @session[:act_inf]
        id = @tick_counter.whose(act_inf[:tick])
        entity = Action::PlaceEntity.find(
          act_inf[:landscape], act_inf[:entities_index], id
        )
        return unless entity.tags.include?(:user_controlled)
        @tick_counter.tick
      end
    end
  end
end
