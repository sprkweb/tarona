module Tarona
  # This class receives connections from players and gives care of them to
  # objects which are needed (socket, server).
  #
  # Instances of this class should be used as Rack application object.
  class Doorman
    # @return [Hash] `game.hash => game` pairs.
    #   `game` is instance of `game` option of {#initialize}
    attr_reader :sessions

    # Create a new doorman. You should pass the returned value to the Rack's
    # `run` method.
    # @option params [Tarona::WebSocket] :io class which can handle
    #   WebSocket connections.
    # @option params [Class] :game its instances will be created as soon as
    #   player will be connected.
    #   It must be inherited from `Tardvig::Command`.
    # @option params [Hash] :game_options this hash (with an `io` instance
    #   added) will be passed as an argument to the `game` constructor.
    # @option params [Object] :server Rack application which respond to HTTP
    #   connections.
    # @return [Doorman] new instancee
    def initialize(params)
      @params = params
      @sessions = {}
    end

    # This method is created for Rack to call it when a new connection is
    # coming. So you would better do not touch it.
    def call(env)
      if @params[:io].player?(env)
        io = @params[:io].new env
        open_game_inst io
        io.response
      else
        @params[:server].call env
      end
    end

    private

    def open_game_inst(io)
      io.on_first :display_ready do |e|
        session_id = e[:session_id]
        if session_id && sessions[session_id]
          old_game_inst session_id, io
        else
          new_game_inst io, e
        end
      end
    end

    def new_game_inst(io, msg)
      options = @params[:game_options].merge io: io
      load_session options, msg[:saved_session] if msg[:saved_session]
      game_inst = @params[:game].call options
      save_new_game_inst game_inst, io
    end

    def old_game_inst(hash, io)
      sessions[hash].io.socket = io.socket
    end

    def save_new_game_inst(game_inst, io)
      hash = game_inst.hash.to_s(16)
      sessions[hash] = game_inst
      io.happen :new_session, hash: hash
    end

    def load_session(options, saved_session)
      options[:saved_data] = saved_session
    end
  end
end
