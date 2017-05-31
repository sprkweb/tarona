module Tarona
  # Command for {Tarona::Act} which extends it by doing jobs when it
  # is requested through its {Tardvig::GameIO}.
  # @abstract You need to make another class which inherits this. One job per
  #   class. Read description of abstract methods of this class and redefine
  #   them. You should not redefine the `#process` method.
  #
  # You must set attributes below using `Tardvig::Command` interface to
  # start this command.
  # @!attribute [r] act
  #   @return [Tarona::Ac] current act.
  #     This command stops working as soon as the act is ended.
  class PrManager < Tardvig::Command
    # This command will do its job only when the certain event is happen.
    # The event name is `:<job_type>_request`.
    # @return [String, Symbol] name of the job which must be done.
    # @note This method must return the same value always.
    # @abstract raises `NotImplemented`
    def job_type
      raise NotImplementedError
    end

    # The job itself. This method is called every time the event is happen.
    # @param event_arg [Object] argument from the event
    # @abstract raises `NotImplemented`
    def job(event_arg)
      raise NotImplementedError
    end

    private

    def process
      event_name = :"#{job_type}_request"
      listener = proc { |*args| job(*args) }
      @act.io.on event_name, &listener
      @act.on :end do
        @act.io.remove_listener event_name, listener
      end
    end
  end
end
