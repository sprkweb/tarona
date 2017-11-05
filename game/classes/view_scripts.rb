module Tarona
  module Game
    # Module for running some scripts on client side from server side.
    module ViewScripts
      module_function

      # @param script [String] this script will be executed on the client side
      def run(io, script)
        io.happen :view_script, script: script
      end
    end
  end
end
