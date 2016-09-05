module Tarona
  # This is a Rack application which handles HTTP requests
  class WebServer < Sinatra::Application
    class << self
      # @return [Tardvig::Toolkit] toolkit
      # @note Toolkit should contain some tools which are needed for server.
      #   For example, `i18n` tool is needed for page translation. It would be
      #   better if you set the same toolkit here as for acts.
      attr_accessor :tk
    end

    helpers do
      # (see tk)
      def tk
        self.class.tk
      end
    end

    configure do
      set :server, :puma
      set :root, PROJECT_ROOT
      set :bind, ENV['IP'] if ENV['IP']
      set :port, ENV['PORT'] if ENV['PORT']
    end
  end
end