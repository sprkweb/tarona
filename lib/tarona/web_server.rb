module Tarona
  class WebServer < Sinatra::Application
    configure do
      set :server, :puma
    end
  end
end