PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
Dir.chdir PROJECT_ROOT
$LOAD_PATH.unshift PROJECT_ROOT

require 'rubygems'
require 'bundler/setup'

require 'json'

require 'tardvig'
require 'rack'
require 'faye/websocket'
require 'sinatra/base'

require 'lib/tarona/version'

require 'lib/tarona/act'
require 'lib/tarona/play'
require 'lib/tarona/play/run_acts'
require 'lib/tarona/doorman'
require 'lib/tarona/web_server'
require 'lib/tarona/web_socket'

require 'lib/tarona/act_types/text_act'
require 'lib/tarona/act_types/action'
require 'lib/tarona/act_types/action/landscape'
require 'lib/tarona/act_types/action/map'

# The main namespace for the gem
module Tarona
end
