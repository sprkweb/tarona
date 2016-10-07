module Tarona
  class Play
    # Part of the Play command which is responsible for sequently running acts.
    # @!attribute [r] acts
    #   @return [Hash] hash containing your acts as values and their
    #     identificators as keys.
    # @!attribute [r] first_act
    #   @return [Object] identificator of the act which must be executed
    #     first.
    # @!attribute [r] act_params
    #   @return [Object] this object will be passed to acts when they are
    #     initialized
    class RunActs < Tardvig::Command
      attr_reader :thread
  
      private
  
      def process
        @thread = Thread.new do
          @next_act = @acts[@first_act]
          until @next_act.nil?
            switch_act
            wait_for_next_act do
              execute_act
            end
          end
        end
      end
  
      def wait_for_next_act
        blocker = new_blocker
        @current_act.on_first :end do |next_act|
          unblock(blocker)
          @next_act = @acts[next_act]
        end
        yield if block_given?
        block_execution(blocker)
      end
  
      def execute_act
        @current_act.call @act_params
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
end