module Tarona
  # Instances of this class are event-driven WebSocket connections using the
  # GameIO interface.
  class WebSocket < Tardvig::GameIO
    def self.player?(env)
      Faye::WebSocket.websocket? env
    end

    def initialize(env)
      @socket = Faye::WebSocket.new env
      set_socket_listeners
    end

    # Changes current WebSocket connection to a new one, so this object will
    # send and get events and other information from it.
    # @param value [Faye::WebSocket] socket object itself
    # @note It is expected that old connection is closed and will not send new
    #   events.
    #   Otherwise, this object can not act properly.
    def socket=(value)
      # Deletion of listeners of an old socket should be here, but
      # I do not know whether it is possible.
      @socket = value
      set_socket_listeners
    end

    alias classic_happen happen
    private :classic_happen

    # It is the same `happen` method, but it also triggers event on the other
    # side of WebSocket.
    def happen(event, data = nil)
      event2output(event, data)
      super(event, data)
    end

    alias trigger happen

    # @return Rack response to make the connection.
    def response
      @socket.rack_response
    end

    private

    def event2output(event, data)
      @socket.send JSON.dump([event, data])
    end

    def input2event(event)
      input = JSON.parse event.data, symbolize_names: true
      return if input.size != 2 || input[0].class != String
      classic_happen input[0].to_sym, input[1]
    end

    def set_socket_listeners
      @socket.on :message, &method(:input2event)
      @socket.on(:open) { classic_happen :open }
    end
  end
end
