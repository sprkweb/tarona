module Tarona
  module Game
    # Module for running some scripts on client side from server side.
    module ViewScripts
      module_function

      # @param script [String] this script will be executed on the client side
      def run(io, script)
        io.happen :view_script, script: script
      end

      # @param effect_name [String] this visual effect will be shown on
      #   client side.
      # @param params [Hash] any additional data for the client side about the
      #   effect (e. g. place).
      def show_effect(io, effect_name, params)
        io.happen :show_visual_effect, name: effect_name, params: params
      end
    end
  end
end
