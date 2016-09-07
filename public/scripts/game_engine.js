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
