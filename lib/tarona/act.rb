module Tarona
  # It is extended tardvig's act.
  #
  # Events:
  #
  # * `end` - you must trigger it when the act execution is ended.
  #   Argument: the identificator of the next act
  class Act < Tardvig::Act
    include Tardvig::Events

    private

    def execute
      deal_with_display
      process
    end

    def deal_with_display
      sender_proc = proc { notify_display }
      @io.on :update_io, &sender_proc
      on_first(:end) { @io.remove_listener :update_io, sender_proc }
      notify_display
    end
  end
end
