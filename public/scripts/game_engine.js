/**
 * Mixin for objects which gives them ability to have events.
 *
 * @mixin
 */
var Events = {
  /**
   * Attachs the given listener to the given event of the object
   *
   * @param event - Identificator of the event. The given listener will be
   *   executed only when event with this identificator will happen
   * @param {function} listener - Callback which will be executed when the event
   *   is happen
   */
  on: function (event, listener) {
    this.listeners(event).push(listener);
  },
  /**
   * Detachs the given listener from the given event of the object.
   * It detachs all the listeners from the event when the listener is not given.
   *
   * @param event - Identificator of the event.
   * @param listener - Listener which must be detached.
   */
  remove_listener: function (event, listener) {
    if (listener !== undefined && this._listeners[event]) {
      this._listeners[event] = _.without(this._listeners[event], listener);
    }
    else {
      this._listeners[event] = [];
    }
  },
  /**
   * Executes all the listeners attached to the given event.
   * The `this` keyword inside the listeners will be the object that has got
   * this event.
   *
   * @param event - All the listeners with this identificator will be executed
   * @param eventData - Whatever you want. It will be passed as an argument to
   *   the listeners.
   */
  happen: function (event, eventData) {
    var self = this;
    this.listeners(event).forEach(function (listener) {
      if (listener) listener.apply(self, [eventData]);
    });
  },
  /**
   * Lists the listeners of the event.
   *
   * @param event - Identificator of the event.
   * @returns {Object[]} array containing the listeners
   */
  listeners: function (event) {
    if (this._listeners === undefined) this._listeners = {};
    if (typeof this._listeners[event] !== 'object') this._listeners[event] = [];
    return this._listeners[event];
  },
  /**
   * This method mixes the mixin in the the given object so it has ability to
   * have events.
   *
   * @param {object} target - Object which must be extended
   * @returns {object} target extended with mixin
   */
  addEventsTo: function(target) {
    var self = this;
    Object.getOwnPropertyNames(this).forEach(function(key) {
      var value = Object.getOwnPropertyDescriptor(self, key);
      Object.defineProperty(target, key, value);
    });
    return target;
  }
};

/**
 * Constructs event-driven WebSocket connection. Events which are triggered on
 * the server side will also be triggered on the client side and vise versa.
 *
 * @param {string} url - URL of the WebSocket server
 * @constructor
 * @mixes Events
 */
function Messenger(url) {
  Events.addEventsTo(this);

  /**
   * This is JavaScript standard WS object.
   * @type {WebSocket}
   */
  this.socket = new WebSocket(url);
  this.socket.onclose = function() {
    // FIXME: Handle the error
  };
  this.socket.onerror = function() {
    // FIXME: Handle the error
  };

  var pure_happen = this.happen;
  var event2output = function (event, eventData) {
    this.socket.send(JSON.stringify([event, eventData]));
  };
  this.happen = function() {
    event2output.apply(this, arguments);
    pure_happen.apply(this, arguments);
  };

  var self = this;
  this.socket.onmessage = function(msg) {
    var msg_content = JSON.parse(msg.data);
    self.listeners(msg_content[0]).forEach(function(listener) {
      if (listener) listener.apply(self, [msg_content[1]]);
    });
  };
}

/**
 * Its instances generates HTML tags for acts. 
 * It is powered by custom "generators", which are functions creating and 
 * managing DOMs for acts (one generator per act).
 * 
 * @constructor
 */
function Display() {
  var generators = {};
  
  var clean = function(area) {
    area.innerHTML = '';
  };
  
  /**
   * Adds your generator to the list of generators.
   * 
   * @param name - identificator of your generator
   * @param {function} func - generator itself
   * @see generate
   */
  this.addGenerator = function(name, func) {
    generators[name] = func;
  };
  
  /**
   * Constructs DOM for your act.
   * 
   * @param generator_name - identificator of a previously added generator
   * @param {object} data - information about your act.
   *   This object will be passed to the generator as an argument.
   *   It must contain attribute `area_selector` which is CSS selector (string)
   *   for the HTML tag which is the root of your act's markup.
   */
  this.generate = function(generator_name, data) {
    var area = document.querySelector(data.area_selector);
    clean(area);
    generators[generator_name](area, data);
  };
};