require 'game/module'
require 'game/classes/acting_entity'
require 'game/toolkit'
require 'game/acts/introduction'
require 'game/acts/placeholder'
require 'game/pages'

toolkit = Tarona::Toolkit
Tarona::WebServer.tk = toolkit.new
doorman = Tarona::Doorman.new(
  io: Tarona::WebSocket,
  server: Tarona::WebServer,
  game: Tarona::Play,
  game_options: {
    acts: { intro: Tarona::Introduction, pholder: Tarona::Placeholder },
    first_act: :intro,
    tk: toolkit
  }
)

unless ENV['RACK_ENV'] == 'test'
  ENV['RACK_ENV'] = 'production'
  rack_options = {
    app: doorman,
    server: :puma
  }
  rack_options[:Port] = ENV['PORT'] if ENV['PORT']
  rack_options[:Host] = ENV['IP'] if ENV['IP']
  Rack::Server.start rack_options
end
