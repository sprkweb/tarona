project_root = File.expand_path('..', File.dirname(__FILE__))
Dir.chdir project_root
$LOAD_PATH.unshift project_root

require 'rubygems'
require 'bundler/setup'

require 'tardvig'
require 'rack'
require 'faye/websocket'
require 'sinatra'

require 'lib/tarona/version'

require 'lib/tarona/act'
require 'lib/tarona/play'
require 'lib/tarona/doorman'
require 'lib/tarona/web_server'
require 'lib/tarona/web_socket'

# The main namespace for the gem
module Tarona
end
