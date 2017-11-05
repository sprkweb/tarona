module Tarona
  # Training act after the interaction.
  class Training < Game::StandardAction
    name :training
    resources << 'game/resources/ground.svg'
    resources << 'game/resources/entities.svg'
    resources << 'game/resources/mirok.svg'

    def process
      io.on_first :map_shown do
        Game::ViewScripts.run io, <<-SCRIPT.gsub(/^ {10}/, '')
          var showText = function(text) {
            var win = new PopUp(env.area, text, { stick_to: 'top-right'});
            win.show();
          };

          showText('#{tk.i18n['game/training_fov'].chomp}');
          showText('#{tk.i18n['game/training_choose'].chomp}');

          var heroSelected = function(ev) {
            if (ev.now.id == 'hero')
              showText('#{tk.i18n['game/training_interact'].chomp}');
            essence.remove_listener('focusChange', heroSelected)
          };
          essence.on('focusChange', heroSelected);
        SCRIPT
      end
    end
  end
end
