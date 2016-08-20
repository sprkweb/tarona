module Tarona
  class WebServer < Sinatra::Application
    configure do
      set :server, :puma
      set :root, PROJECT_ROOT
      set :bind, ENV['IP'] if ENV['IP']
      set :port, ENV['PORT'] if ENV['PORT']
    end
  end
end