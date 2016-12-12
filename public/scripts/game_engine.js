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
    pure_happen.apply(self, JSON.parse(msg.data));
  };
  this.socket.onopen = function() {
    pure_happen.apply(self, ['open']);
  };
}

/**
 * Its instances generates HTML tags for acts.
 * It is powered by custom "generators", which are functions creating and
 * managing DOMs for acts (one generator per act).
 *
 * @constructor
 * @param {object} env - object containing environment objects which are needed
 *   to generators (e. g. I/O object, tag selector, etc.)
 * @param {string} env.area_selector - CSS selector of the container tag.
 *   Generators will create tags only inside this tag.
 * @mixes Events
 */
function Display(env) {
  Events.addEventsTo(this);

  /**
   * List of generators which you have previously added:
   * @example
   * { generator_name: function() {} }
   */
  this.generators = {};

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
    this.generators[name] = func;
  };

  /**
   * Constructs DOM for your act.
   *
   * @param generator_name - identificator of a previously added generator
   * @param {object} data - information about your act.
   *   This object will be passed to the generator as an argument.
   *   It must contain attribute `area_selector` which is CSS selector (string)
   *   for the HTML tag which is the root of your act's markup.
   * @fires Display#event:before_act
   */
  this.generate = function(generator_name, data) {
    /**
     * This event is happened before an act is generated.
     *
     * @event Display#event:before_act
     * @type {object}
     * @property type - name of the used generator
     * @property data - properties of the act which are passed to the generator
     */
    this.happen('before_act', { type: generator_name, data: data })
    var area = document.querySelector(env.area_selector);
    var extended_env = _.extend(_.clone(env), { area: area });
    clean(area);
    this.generators[generator_name](extended_env, data);
  };
}

/**
 * Generator of text acts for Display
 * @see Display
 */
function TextGenerator(env, data) {
  var container = env.area.appendChild(document.createElement('div'));
  container.setAttribute('id', 'text');
  container.innerHTML = data.subject;

  var heRead = function() {
    document.removeEventListener('keyup', heRead);
    env.area.removeEventListener('click', heRead);
    env.io.happen('read');
 };
  document.addEventListener('keyup', heRead);
  env.area.addEventListener('click', heRead);
}

/**
 * Object containing some W3 specifications of namespaces.
 * @global
 */
var NS = {
  SVG: 'http://www.w3.org/2000/svg',
  XLINK: 'http://www.w3.org/1999/xlink'
};

/**
 * Generator of action for Display. It builds and manages hexagonal grid and
 * things which are placed on it.
 * @see Display
 */
function ActionGenerator(env, data) {
  /*
  There are some classes. They are not documented and tested. It is because
  they are private.
  */
  var Hex = function(size) {
    this.size = size;

    this._corner = function (center, i) {
      var angle_deg = 60 * i + 30;
      var angle_rad = Math.PI / 180 * angle_deg;
      return {
          x: center.x + this.size * Math.cos(angle_rad),
          y: center.y + this.size * Math.sin(angle_rad)
        };
    };
    this._points = function (center) {
      var pointsArray = [];
      for (var i = 0; i < 6; i++) {
        pointsArray[i] = this._corner(center, i);
      }
      return pointsArray;
    };

    var round_to = function (num, precision) {
        var f = Math.pow(10, precision);
        return Math.round(num * f) / f;
    };
    this.generateLine = function (center) {
      var point_to_str = function (point) {
        return round_to(point.x, 10) + ' ' + round_to(point.y, 10);
      };
      var points = this._points(center);
      var pointsString = 'M ' + point_to_str(points[0]) + ' ';
      for (var i = 1; i < points.length; i++) {
        pointsString += 'L ' + point_to_str(points[i]) + ' ';
      }
      pointsString += 'Z';
      return pointsString;
    };
    this.width = this.size * Math.sqrt(3);
    this.height = this.size * 2;
    this.verticalSpace = this.size * 3 / 2;
  }

  var HexGrid = {
    coords2px: function (coords, hex) {
      var x = hex.width * (coords[0] + 0.5 * (coords[1] % 2) + 0.5);
      var y = hex.verticalSpace * coords[1] + hex.height / 2;
      return [x, y];
    },
    px2coords: function (px, hex) {
      q = 2 * px[0] / (hex.size * 3);
      r = (Math.sqrt(3) * px[1] - px[0]) / (hex.size * 3);
      return _axial2coords(_axial_coords_round([q, r]));
    },

    height: function (rows, hex) {
      return (rows - 1) * hex.verticalSpace + hex.height;
    },
    width: function (cols, hex) {
      return (cols + 0.5) * hex.width;
    },

    _axiaL_coords_round: function (coords) {
      var x = coords[0],         z = coords[1],         y = - (x + z);
      var rx = Math.round(x),    rz = Math.round(z),    ry = Math.round(y);
      var dx = Math.abs(rx - x), dz = Math.abs(rz - z), dy = Math.abs(ry - y);
      if ((x_diff > y_diff) && (x_diff > z_diff))
        rx = - (ry + rz);
      else if (y_diff <= z_diff)
        rz = - (rx + ry);
      return [rx, rz];
    },
    _axial2coords: function (axial) {
      return [q + (r - (r % 2)) / 2, r];
    }
  };

  var SVGHex = function(place, options) {
    if (typeof options != 'object') options = {};
    this.options = _.extend({
      templateId: '',
      backgroundId: ''
    }, options);
    this.place = place;
    this.backgroundElem = null;

    this.generate = function() {
      this._generateBackground();
    };

    this.getBackgroundElem = function() { return this.backgroundElem; };

    this._generateBackground = function() {
      var bgElem = this._generateUse();
      bgElem.setAttribute('fill', 'url(#' + this.options.backgroundId + ')');
      bgElem.setAttribute('stroke', 'url(#' + this.options.backgroundId + ')');
      this.options.backgroundParentElem.appendChild(bgElem);
      this.backgroundElem = bgElem;
    };

    this._generateUse = function() {
      var elem = document.createElementNS(NS.SVG, 'use');
      elem.setAttribute('x', this.place[0]);
      elem.setAttribute('y', this.place[1]);
      elem.setAttributeNS(NS.XLINK, 'href', '#' + this.options.templateId);
      return elem;
    };
  };

  var Entity = function(options) {
    Events.addEventsTo(this);

    this.move = function(coordinates) {
      if (coordinates) {
        this.changePlace(HexGrid.coords2px(coordinates, this.hex));
        this.coordinates = coordinates;
      }
    };

    this.changePlace = function(place) {
      if (place) {
        this.elem.setAttribute('x', place[0]);
        this.elem.setAttribute('y', place[1])
      }
    };

    this.changeTemplate = function(template_id) {
      if (template_id)
        this.elem.setAttributeNS(NS.XLINK, 'href', '#' + template_id);
    };

    this.hexes = function() {
      var hexes = [];
      var self = this;
      options.hexes.forEach(function(hex) {
        hexes.push([self.coordinates[0] + hex[0], self.coordinates[1] + hex[1]]);
      });
      return hexes;
    };

    this.id = options.id;
    this.hex = options.hex;
    this.coordinates = null;
    this.elem = document.createElementNS(NS.SVG, 'use');
    this.changeTemplate(options.svg_id);
    if (options.place) this.move(options.place);
  };

  var wrapper = env.area.appendChild(document.createElement('div'));
  wrapper.setAttribute('id', 'field');
  var field = wrapper.appendChild(document.createElementNS(NS.SVG, 'svg'));
  var defs = field.appendChild(document.createElementNS(NS.SVG, 'defs'));

  var length = function(x) { return x.length };
  var cols = data.subject.landscape.length;
  var rows = _.max(data.subject.landscape, length).length;
  var hex = new Hex(data.subject.hex_size);
  var hexes = [];
  var width, height;
  var hexesElem, entitiesElem;

  var loadSVGDependencies = function(resources) {
    defs.innerHTML += resources;
  };

  var generateHexClipPath = function() {
    var clip = defs.appendChild(document.createElementNS(NS.SVG, 'clipPath'));
    clip.setAttribute('id', 'hexclip');
    var clipEl = clip.appendChild(document.createElementNS(NS.SVG, 'use'));
    clipEl.setAttribute('x', '0');
    clipEl.setAttribute('y', '0');
    clipEl.setAttribute('href', '#hex');
  };

  var generateStandartHex = function() {
    var pathElem = defs.appendChild(document.createElementNS(NS.SVG, 'path'));
    pathElem.setAttribute('d', hex.generateLine({ x: 0, y: 0 }) );
    pathElem.setAttribute('id', 'hex');
    generateHexClipPath();
  };

  var generateGroups = function() {
    hexesElem = document.createElementNS(NS.SVG, 'g');
    entitiesElem = document.createElementNS(NS.SVG, 'g');
    hexesElem.setAttribute('id', 'hexes');
    entitiesElem.setAttribute('id', 'entities');
    field.appendChild(hexesElem);
    field.appendChild(entitiesElem);
  };

  var addHex = function(coordinates, options) {
    if (typeof options !== 'object') options = {};
    var place = HexGrid.coords2px(coordinates, hex);
    options = {
      backgroundId: (options.g ? options.g.svg_id : '' ),
      backgroundParentElem: hexesElem,
      templateId: 'hex'
    };
    var svgHex = new SVGHex(place, options);
    svgHex.coordinates = coordinates;
    svgHex.generate();
    var x = coordinates[0], y = coordinates[1];
    if (typeof hexes[x] === 'undefined') hexes[x] = [];
    hexes[x][y] = svgHex;
  };

  var addEntity = function(entity_data, coordinates) {
    var entity = new Entity(_.extend(entity_data, {
      place: coordinates,
      hex: hex
    }));
    entitiesElem.appendChild(entity.elem);
    return entity;
  };

  var scale = function() {
    width = HexGrid.width(cols, hex);
    height = HexGrid.height(rows, hex);
    field.setAttribute('height', height);
    field.setAttribute('width', width);
    field.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
  };

  var generateField = function(map, resources) {
    map.forEach(function(col, colNum) {
      col.forEach(function(place, rowNum) {
          var coordinates = [colNum, rowNum];
          addHex(coordinates, place);
          if (place.e) place.e.forEach(function(entity) {
              addEntity(entity, coordinates);
            });
      });
    });
  };

  generateStandartHex();
  loadSVGDependencies(data.subject.dependencies);
  generateGroups();
  generateField(data.subject.landscape, data.subject.dependencies);
  scale();
}
