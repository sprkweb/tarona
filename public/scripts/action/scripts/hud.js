/**
 * Namespace for HUD-related things.
 *
 * @namespace
 * @see HUD.Generator
 */
var HUD = {
  /**
   * Script for Action.Generator which generates HUD with different useful
   * information for player.
   * It makes it from different parts. You can see these parts inside the
   * {@link HUD} namespace.
   *
   * @see Action.Generator
   */
  Generator: function(env, data, essence) {
    var createContainer = function(env) {
      var container = env.area.appendChild(document.createElement('div'));
      container.classList.add('hud');
      return container;
    };

    var parts = [
      HUD.EntityInfo,
      HUD.HighlightHexes,

      HUD.Space,

      HUD.SkipTick
    ];
    var container = createContainer(env);
    parts.forEach(function(part) {
      var partElem = part(env, data, essence);
      if (partElem instanceof Element) container.appendChild(partElem);
    });
  },

  Space: function() {
    var space = document.createElement('div');
    space.classList.add('hud-space');
    return space;
  },

  /**
   * Part of the {@link HUD.Generator}.
   * It shows information about focused entity.
   *
   * It requests information about it from server using the
   * `entity_info_request` event with attribute `id` (Entity's id).
   * It shows the information when server responds with the `entity_info_show`
   * event with attributes: `hp`, `max_hp`, `energy`, `max_energy`.
   */
  EntityInfo: function(env, data, essence) {
    var container = document.createElement('div');
    container.classList.add('info_list');

    var init = function() {
      essence.on('focusChange', requestInfo);
      env.io.on('tick_start', requestInfo);
      env.io.on('entity_info_show', showInfo);
      env.display.on('before_act', function() {
        essence.remove_listener('focusChange', requestInfo);
        env.io.remove_listener('entity_info_show', showInfo);
      });
    };

    var requestInfo = function() {
      if (essence.focused)
        env.io.happen('entity_info_request', { id: essence.focused.id });
    };

    var showInfo = function(inf) {
      container.innerHTML = '';
      if (inf.name) {
        var name_elem = container.appendChild(document.createElement('p'));
        name_elem.innerHTML = data.subject.i18n[inf.name] || inf.name;
      }
      if (inf.hp && inf.max_hp)
        displayParam(container, 'health', inf.hp + '/' + inf.max_hp);
      if (inf.energy && inf.max_energy)
        displayParam(container, 'energy', inf.energy + '/' + inf.max_energy);
    };

    var displayParam = function(container, name, display_text) {
      var param = container.appendChild(document.createElement('p'));
      var param_label = param.appendChild(document.createElement('span'));
      param_label.innerHTML = data.subject.i18n['entity_info/' + name] + ': ';
      var param_display = param.appendChild(document.createElement('span'));
      param_display.innerHTML = display_text;
    };

    init();
    return container;
  },

  /**
   * Part of the {@link HUD.Generator}.
   * Highlights hexagons:
   *
   * - Under focused entity
   * - Available paths for player's movable entity
   *
   * @see Action.Generator
   */
  HighlightHexes: function(env, _data, essence) {
    var Highlight = function(klass) {
      this.klass = klass;
      this.nowHighlighted = [];

      this.highlight = function(hexes) {
        var self = this;
        hexes.forEach(function(hex) {
          var hex_obj = essence.hexes[hex[0]][hex[1]];
          hex_obj.backgroundElem.classList.add(self.klass);
          self.nowHighlighted.push(hex_obj);
        });
      };

      this.clear = function() {
        if (this.nowHighlighted === []) return;
        var self = this;
        this.nowHighlighted.forEach(function(hex) {
          hex.backgroundElem.classList.remove(self.klass);
        });
       this.nowHighlighted = [];
      };

      this.change = function(hexes) {
        this.clear();
        this.highlight(hexes);
      };
    };

    // Focused entity highlight
    var focusedHighlight = new Highlight('focused');
    var focusedEntity = null;
    var highlightNewFocus = function(inf) {
      focusedHighlight.clear();
      focusedEntity = null;
      if (inf.now && inf.now.hexes) {
        focusedHighlight.highlight(inf.now.hexes());
        focusedEntity = inf.now;
      }
    };
    essence.on('focusChange', highlightNewFocus);
    var move_highlight = function(inf) {
     var entity = essence.entities[inf.entity_id];
     if ((focusedEntity == entity) && inf.to)
       focusedHighlight.change(entity.hexes(inf.to));
    };
    env.io.on('move', move_highlight);

    // Available movement highlight
    var reachableHighlight = new Highlight('reachable');
    var requestMovementPotential = function() {
      reachableHighlight.clear();
      var focused = essence.focused;
      if (focused)
        env.io.happen('movement_potential_request', { entity_id: focused.id });
    };
    essence.on('focusChange', requestMovementPotential);
    env.io.on('tick_start', requestMovementPotential);
    var showMovementPotential = function(msg) {
      var sameEntity = msg.entity_id == essence.focused.id;
      var shownCenter = essence.focused.coordinates;
      var samePlace =
        msg.from[0] == shownCenter[0] && msg.from[1] == shownCenter[1];
      if (sameEntity && samePlace)
        reachableHighlight.change(_.map(msg.reachable.places, _.first));
    };
    env.io.on('movement_potential_show', showMovementPotential);

    env.display.on('before_act', function() {
      essence.remove_listener('focusChange', highlightNewFocus);
      env.io.remove_listener('move', move_highlight);

      essence.remove_listener('focusChange', requestMovementPotential);
      env.io.remove_listener('tick_start', requestMovementPotential);
      env.io.remove_listener('movement_potential_show', showMovementPotential);
    });
  },

  SkipTick: function(env, data) {
    var button = document.createElement('button');
    button.innerHTML = data.subject.i18n['hud/skip_tick'];
    button.addEventListener('click', function() {
      env.io.happen('skip_tick_request');
    });
    return button;
  }
};
