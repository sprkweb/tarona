module Tarona
  # Instances of this class are event-driven WebSocket connections using the
  # GameIO interface.
  class WebSocket < Tardvig::GameIO
    def self.player?(env)
      Faye::WebSocket.websocket? env
    end

    def initialize(env)
      @socket = Faye::WebSocket.new env
      @socket.on :message, &method(:input2event)
      @socket.on(:open) { classic_happen :open }
    end

    alias classic_happen happen
    private :classic_happen

    # It is the same `happen` method, but it also triggers event on the other
    # side of WebSocket.
    def happen(event, data)
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
      input = JSON.parse event.data
      return if input.size != 2 || input[0].class != String
      classic_happen input[0].to_sym, input[1]
    end
  end
end
