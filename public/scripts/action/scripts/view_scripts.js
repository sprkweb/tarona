/**
 * Script for Action.Generator which adds ability to run scripts which are
 * send from server.
 *
 * @see Action.Generator
 */
function ViewScripts(env, data, essence) {
  var self = this;
  this._init = function() {
    env.io.on('view_script', self._run);
    env.io.on('show_visual_effect', self._visualEffect);
    env.display.on_first('before_act', function() {
      env.io.remove_listener('view_script', self._run);
      env.io.remove_listener('show_visual_effect', self._visualEffect);
    });
    env.io.happen('map_shown');
  };

  this._run = function(ev) {
    var script = new Function('env, data, essence', ev.script);
    script(env, data, essence);
  };

  this._visualEffect = function(ev) {
    ViewScripts.EFFECTS[ev.name](env, data, essence, ev.params);
  };

  this._init();
}

ViewScripts.EFFECTS = {
  lazer_shot: function(env, data, essence, params) {
    var elem = document.createElementNS(NS.SVG, 'line');
    var beginPlace = Action.HexGrid.coords2px(params.from, essence.hex);
    var endPlace = Action.HexGrid.coords2px(params.to, essence.hex);
    elem.setAttribute('x1', beginPlace[0]);
    elem.setAttribute('y1', beginPlace[1]);
    elem.setAttribute('x2', beginPlace[0]);
    elem.setAttribute('y2', beginPlace[1]);
    elem.setAttribute('stroke', '#ffffff');
    elem.setAttribute('stroke-width', '2');
    elem.setAttribute('filter', 'url(#lazer_light)');
    essence.field.appendChild(elem);
    Animate(elem, { x2: endPlace[0], y2: endPlace[1] },
      { duration: 50, easing: 'linear', delay: 50 });
    Animate(elem, { x1: endPlace[0], y1: endPlace[1] },
      { duration: 50, easing: 'linear',
        complete: function() {
          essence.field.removeChild(elem);
        }
      });
  },
  }
};
