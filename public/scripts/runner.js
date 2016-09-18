/**
 * The main module of the JS part of the game. It combines all of the other
 * modules together and runs them.
 * 
 * @constructor
 */
function Runner() {
  runner = this;

  /**
   * A display for the current game. 
   * Contents act types' generators and runs them.
   *
   * @type Display
   */
  this.display = new Display();
  this.display.addGenerator('text', TextGenerator);

  /**
   * A messenger for the current game. Connects JavaScript to the back-end.
   *
   * @type Messenger
   */
  this.messenger = new Messenger(location.origin.replace(/^http/, 'ws'));
  this.messenger.on('act_start', function(act) {
    runner.display.generate(act.type, act.subject);
  });
}

new Runner();
