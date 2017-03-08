/**
 * The main module of the JS part of the game. It combines all of the other
 * modules together and runs them.
 *
 * @constructor
 */
function Runner() {
  runner = this;

  /**
   * A messenger for the current game. Connects JavaScript to the back-end.
   *
   * @type Messenger
   */
  this.messenger = new Messenger(location.origin.replace(/^http/, 'ws'));
  this.messenger.on('open', function() {
    var session_id = document.cookie.match(/session_id=([-a-zA-Z0-9]+)(;|$)/);
    if (session_id) session_id = session_id[1];
    this.happen('display_ready', { session_id: session_id });
  });
  this.messenger.on('new_session', function(inf) {
    document.cookie = 'session_id=' + inf.hash;
  });
  this.messenger.on('act_start', function(act) {
    runner.display.generate(act.type, act);
  });

  /**
   * A display for the current game.
   * Contents act types' generators and runs them.
   *
   * @type Display
   */
  this.display = new Display({
    area_selector: '#area',
    io: this.messenger,
    scripts: [HighlightHexes, PlayerInteract, FovOperator]
  });
  this.display.addGenerator('text', TextGenerator);
  this.display.addGenerator('action', Action.Generator);

  this.keybindings = new Keybindings(this.display);
  this.display.env.keybindings = this.keybindings;
}

if (typeof environment === 'undefined') {
  var environment = 'production';
}

if (environment !== 'test') {
  new Runner();
}
