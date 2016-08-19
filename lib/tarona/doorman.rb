module Tarona
  # This class receives connections from players and gives care of them to
  # objects which are needed (socket, server).
  #
  # Instances of this class should be used as Rack application object.
  class Doorman
    # Create a new doorman. You should pass the returned value to the Rack's
    # `run` method.
    # @param acts [Hash] hash containing your acts as values and their
    #   identificators as keys.
    # @param first_act [Object] identificator of the act which must be executed
    #   first.
    # @return [Doorman] new instacne
    def initialize(acts, first_act)
      @acts = acts
      @first_act = first_act
    end

    # This method is created for Rack to call it when a new connection is
    # coming. So you would better do not touch it.
    def call(env)
      if Tarona::WebSocket.websocket?(env)
        io = Tarona::WebSocket.new env
        Tarona::Play.new io: io, acts: @acts, first_act: @first_act
      else
        Tarona::WebServer.call env
      end
    end
  end
end