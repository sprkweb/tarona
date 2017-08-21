require 'game/module'
require 'game/classes/interaction'
require 'game/classes/interactions_judge'
require 'game/classes/attack'
require 'game/classes/move_types/standard_walking'
require 'game/classes/entities/fighter'
require 'game/classes/hud_support'
require 'game/classes/hud_support/informer'
require 'game/classes/hud_support/entity_info'
require 'game/classes/hud_support/movement_potential'
require 'game/classes/tick_counter'
require 'game/classes/death'
require 'game/classes/standard_rules'
require 'game/classes/standard_action'
require 'game/toolkit'
require 'game/acts/introduction'
require 'game/acts/placeholder'
require 'game/acts/the_end'
require 'game/pages'

toolkit = Tarona::Toolkit
Tarona::WebServer.tk = toolkit.new
doorman = Tarona::Doorman.new(
  io: Tarona::WebSocket,
  server: Tarona::WebServer,
  game: Tarona::Play,
  game_options: {
    acts: {
      intro: Tarona::Introduction,
      pholder: Tarona::Placeholder,
      the_end: Tarona::TheEnd
    },
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
