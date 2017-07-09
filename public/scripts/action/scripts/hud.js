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

    var parts = [HUD.EntityInfo];
    var container = createContainer(env);
    parts.forEach(function(part) {
      container.appendChild(part(env, data, essence));
    });
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
  }
};
