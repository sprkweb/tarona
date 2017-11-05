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
    env.display.on_first('before_act', function() {
      env.io.remove_listener('view_script', self._run);
    });
    env.io.happen('map_shown');
  };

  this._run = function(ev) {
    var script = new Function('env, data, essence', ev.script);
    script(env, data, essence);
  };

  this._init();
}
