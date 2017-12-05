module Tarona
  # Training act after the interaction.
  class Training < Game::StandardAction
    name :training
    resources << 'game/resources/ground.svg'
    resources << 'game/resources/entities.svg'
    resources << 'game/resources/effects.svg'
    resources << 'game/resources/mirok.svg'

    def process
      index = @tk.session[:act_inf][:entities_index]
      game_over ||= proc do
        unless index['hero']
          happen :end, :game_over
          rules.tick_counter.remove_listener(:tick_start, game_over)
        end
      end
      rules.tick_counter.on(:tick_start, &game_over)
      io.on_first :map_shown do
        show_controls_info
        when_he_shot_crystal do
          add_radls
          say_to_hide
          wait_until_hide do |hero_place|
            act_end hero_place
          end
        end
      end
    end

    def show_controls_info
      Game::ViewScripts.run io, <<-SCRIPT.gsub(/^ {10}/, '')
        var openedWins = [];
        var showText = function(text) {
          var win = new PopUp(env.area, text, { stick_to: 'top-right' });
          win.show();
          openedWins.push(win);
        };
        var clearPopups = function() {
          openedWins.forEach(function(w) { w.close() });
        };

        showText('#{tk.i18n['game/training_fov'].chomp}');
        showText('#{tk.i18n['game/training_choose'].chomp}');

        var heroSelected = function(ev) {
          clearPopups();
          if (ev.now.id == 'hero')
            showText('#{tk.i18n['game/training_interact'].chomp}');
          essence.remove_listener('focusChange', heroSelected)
        };
        essence.on('focusChange', heroSelected);
      SCRIPT
    end

    def when_he_shot_crystal(&block)
      judge = rules.interactions_judge
      after_shot = proc do |ev|
        if he_shot_crystal?(ev)
          judge.remove_listener(:after_interact, after_shot)
          block.call
        end
      end
      judge.on(:after_interact, &after_shot)
    end

    def he_shot_crystal?(ev)
      ev[:from].id == 'hero' && ev[:to].id == 'crystal3' &&
        ev[:interaction] == ev[:from].interactions['lazer_rifle_shoot']
    end

    def add_radls
      act_inf = @tk.session[:act_inf]
      radl_class = Game::Templates::RadlSoldier
      list = [['1', [52, 22]], ['2', [57, 28]], ['3', [53, 31]],
        ['4', [58, 21]], ['5', [57, 17]], ['6', [57, 37]], ['7', [55, 40]]]
      list.each do |inf|
        obj = radl_class.new(
          "radl_soldier#{inf[0]}", radl_class::TEMPLATE, hp: radl_class::MAX_HP
        )
        Action::PlaceEntity.add(act_inf[:landscape], obj, inf[1])
        act_inf[:entities_index][obj.id] = inf[1]
        rules.tick_counter.candidates << obj
        io.happen :add_entity, entity_inf: obj.raw, place: inf[1]
      end
    end

    def say_to_hide
      Game::ViewScripts.run io, <<-SCRIPT.gsub(/^ {10}/, '')
        (new PopUp(env.area, '#{tk.i18n['game/training_hide'].chomp}',
          { stick_to: 'top-right' })).show();
      SCRIPT
    end

    def wait_until_hide(&block)
      check_if_hid = proc do
        hero_place = @tk.session[:act_inf][:entities_index]['hero']
        dist = Action::Cartographer.distance [28, 24], hero_place
        if dist < 3
          rules.mobilize.remove_listener(:after_move, check_if_hid)
          block.call hero_place
        end
      end
      rules.mobilize.on(:after_move, &check_if_hid)
    end

    def act_end(hero_place)
      index = @tk.session[:act_inf][:entities_index]
      landscape = @tk.session[:act_inf][:landscape]
      hero = Action::PlaceEntity.find landscape, index, 'hero'
      enemy = Game::AI::Standard.find_nearest_entity hero, @tk.session do |e|
        e.respond_to?(:side) && e.side != hero.side && e.respond_to?(:hp)
      end
      params = { from: index[enemy.id], to: [hero_place[0] - 2, hero_place[1]] }
      Game::ViewScripts.show_effect io, :grenade_throw, params
      sleep 0.4
      happen :end, :to_be_continued
    end
  end
end
