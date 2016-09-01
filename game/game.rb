require 'game/toolkit'
require 'game/acts/introduction'
require 'game/pages'

toolkit = Tarona::Toolkit.new
Tarona::WebServer.tk = toolkit
doorman = Tarona::Doorman.new(
  io: Tarona::WebSocket,
  server: Tarona::WebServer,
  game: Tarona::Play,
  game_options: {
    acts: { intro: Tarona::Introduction },
    first_act: :intro,
    tk: toolkit
  }
)
Rack::Server.start app: doorman unless ENV['RACK_ENV'] == 'test'