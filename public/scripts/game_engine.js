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
   * <br>
   * <strong>This method is not mixed to other objects.</strong>
   * Actually, I do not know how to say that to JSDoc.
   *
   * @param {object} target - Object which must be extended
   * @returns {object} target extended with mixin
   * @protected
   */
  addEventsTo: function(target) {
    var self = this;
    Object.getOwnPropertyNames(Events).forEach(function(key) {
      if (key === 'addEventsTo') return;
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
   * @type {object}
   * @see arguments given
   */
  this.env = env;

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
 * @namespace
 */
var NS = {
  SVG: 'http://www.w3.org/2000/svg',
  XLINK: 'http://www.w3.org/1999/xlink'
};

/**
 * Contains {@link Action.Generator} and related things.
 *
 * @namespace
 */
var Action = {
  // These intefaces are used for DRY documentation.
  /**
   * Two-dimensional array, its indexes are coordinates of corresponding places.
   *
   * @interface Action.Grid
   * @example
   * grid[x][y] = val; // means: "val" is placed at (x, y).
   */

  /**
   * Array with two elements: x and y
   *
   * @interface Action.Coordinates
   * @example
   * [x, y] // means (x, y) coordinate.
   */

  /**
   * Geometric description of a regular hexagon.
   * You need to give its size, other characteristics will be calculated.
   *
   * @constructor
   * @param {number} size - distance from hexagon's center to its vertices.
   */
  Hex: function(size) {
    /**
     * @see arguments given
     * @type number
     * @readonly
     */
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
    /**
     * @param {object} center - coordinates of the center point of the hexagon.
     *   It must contain x and y keys.
     * @return {string} svg border line description for this hexagon.
     *   See documentation for the "d" SVG attribute.
     */
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
    /**
     * Width of a hexagon with given size.
     * @type number
     * @readonly
     */
    this.width = this.size * Math.sqrt(3);
    /**
     * Height of a hexagon with given size.
     * @type number
     * @readonly
     */
    this.height = this.size * 2;
    /**
     * How much vertical space does the hexagon takes when it is placed into
     * pattern.
     * @see http://www.redblobgames.com/grids/hexagons/#basics
     * @type number
     * @readonly
     */
     this.verticalSpace = this.size * 3 / 2;
  },

  /**
   * Some useful methods for calculating various properties of hexagonal grid.
   * Type of the grid is "pointy-topped odd-r".
   * @see http://www.redblobgames.com/grids/hexagons/
   * @namespace
   */
  HexGrid: {
    /**
     * Calculates where is a hexagon with given coordinates placed.
     * @param {Action.Coordinates} coords - coordinates of the hexagon
     * @param {Action.Hex} hex - the hexagon itself
     * @return {Action.Coordinates} coordinates in pixels from top-left corner
     */
    coords2px: function (coords, hex) {
      var x = hex.width * (coords[0] + 0.5 * (coords[1] % 2) + 0.5);
      var y = hex.verticalSpace * coords[1] + hex.height / 2;
      return [x, y];
    },
    /**
     * Calculates coordinates of a hexagon using its coordinates in pixels.
     * @param {Action.Coordinates} px - coordinates in pixels
     *   from top-left corner
     * @param {Action.Hex} hex - the hexagon itself
     * @return {Action.Coordinates} coordinates of the hexagon
     */
    px2coords: function (px, hex) {
      var x = px[0] - hex.width / 2;
      var y = px[1] - hex.height / 2;
      var q = (x * Math.sqrt(3)/3 - y / 3) / hex.size;
      var r = y * 2/3 / hex.size;
      return this._axial2coords(this._axial_coords_round([q, r]));
    },

    /**
     * Calculates height of a hexagonal grid.
     * @param {number} rows - how much rows does the grid have
     * @param {Action.Hex} hex - description of element of the grid
     * @return {number} height of a hexagonal grid.
     */
    height: function (rows, hex) {
      return (rows - 1) * hex.verticalSpace + hex.height;
    },
    /**
     * Calculates width of a hexagonal grid.
     * @param {number} cols - how much columns does the grid have
     * @param {Action.Hex} hex - description of element of the grid
     * @return {number} width of a hexagonal grid.
     */
    width: function (cols, hex) {
      return (cols + 0.5) * hex.width;
    },

    _axial_coords_round: function (coords) {
      var x = coords[0],         z = coords[1],         y = - (x + z);
      var rx = Math.round(x),    rz = Math.round(z),    ry = Math.round(y);
      var dx = Math.abs(rx - x), dz = Math.abs(rz - z), dy = Math.abs(ry - y);
      if ((dx > dy) && (dx > dz))
        rx = - (ry + rz);
      else if (dy <= dz)
        rz = - (rx + ry);
      return [rx, rz];
    },
    _axial2coords: function (axial) {
      var q = axial[0], r = axial[1];
      return [q + (r - (r % 2)) / 2, r];
    }
  },

  /**
   * Represents visualization of an entity.
   *
   * @constructor
   * @param {object} options - some properties of the entity.
   * @param {string} options.id - identificator of the entity
   * @param {string} options.svg_id - "id" attribute of template
   *   definition - element inside the "defs" container.
   *   It will be used to create visualization
   * @param {Action.Hex} options.hex - element of the grid
   *   on which the entity is placed
   * @param {Action.Coordinates} options.place - coordinates of the central
   *   point of the entity.
   * @param {object<Array<Action.Coordinates>>} options.hexes - which places
   *   does the entity takes relatively to itself.<br>
   *   Object has two keys: even_row contains array with hexes which the entity
   *   takes when it stands on row with even number, odd_row - with odd number.
   */
  Entity: function(options) {
    /**
     * Changes entity's coordinates and moves its visualization.
     *
     * @param {Action.Coordinates} coordinates - entity will be placed there.
     */
    this.move = function(coordinates) {
      if (coordinates) {
        this.changePlace(Action.HexGrid.coords2px(coordinates, this.hex));
        this.coordinates = coordinates;
      }
    };

    /**
     * Moves visualization of the entity.
     * Unlike #move, it does not changes its coordinates and receives
     * coordinates in pixels.
     *
     * @param {Action.Coordinates} place - entity will be placed here (pixels)
     */
    this.changePlace = function(place) {
      if (place) {
        this.elem.setAttribute('x', place[0]);
        this.elem.setAttribute('y', place[1])
      }
    };

    /**
     * Changes template of the entity, so it looks in other way.
     *
     * @param {string} template_id - "id" attribute of template
     *   definition - element inside the "defs" container.
     */
    this.changeTemplate = function(template_id) {
      if (template_id)
        this.elem.setAttributeNS(NS.XLINK, 'href', '#' + template_id);
    };

    /**
     * @param {?Action.Coordinates} coords - if it is given, hexes will be
     *   calculated as if it is the entity's center.
     * @returns {Array<Action.Coordinates>} coordinates of hexes which is taken
     *   by the entity
     */
    this.hexes = function(coords) {
      if (coords)
        var x = coords[0], y = coords[1];
      else
        var x = this.coordinates[0], y = this.coordinates[1];
      var relative_places = options.hexes[y % 2 == 0 ? 'even_row' : 'odd_row'];
      var hexes = [];
      relative_places.forEach(function(hex) {
        hexes.push([x + hex[0], y + hex[1]]);
      });
      return hexes;
    };

    /**
     * @see arguments given
     * @type string
     */
    this.id = options.id;
    /**
     * @see arguments given
     * @type Action.Hex
     */
    this.hex = options.hex;
    /**
     * Coordinates of the entity. Unit is hexagon, not pixel.
     * @see Action.HexGrid
     * @type Action.Coordinates
     */
    this.coordinates = null;
    /**
     * Element which shows entity. Note, Entity object does not insert it into
     * DOM, you should do it by yourself.
     * @type SVGUseElement
     */
    this.elem = document.createElementNS(NS.SVG, 'use');
    this.elem.setAttribute('data-type', 'entity');
    this.elem.setAttribute('data-entity_id', this.id);
    this.changeTemplate(options.svg_id);
    if (options.place) this.move(options.place);
  },

  /**
   * Represents visualization of an individual hexagon.
   *
   * @constructor
   * @param {Action.Coordinates} place - where is the hexagon (pixels).
   * @param {object} options - some properties of the hex.
   * @param {string} options.templateId - "id" attribute of template
   *   definition - element inside the "defs" container
   *   which looks like the hex. Its shape will be used to create visualization.
   * @param {string} options.backgroundId - "id" attribute of pattern
   *   definition - element inside the "defs" container.
   *   It will be used as fill for hexagon's background.
   * @param {Element} options.backgroundParentElem - container
   *   for hexes [background] elements.
   *   Visualization will be placed here.
   */
  SVGHex: function(place, options) {
    if (typeof options != 'object') options = {};
    /**
     * @see arguments given
     * @type object
     */
    this.options = options;
    /**
     * @see arguments given
     * @type Action.Coodinates
     * @readonly
     */
    this.place = place;
    /**
     * Element which shows hexagon's background
     * @type SVGElement
     * @readonly
     */
    this.backgroundElem = null;

    /**
     * Generates visualization.
     */
    this.generate = function() {
      this._generateBackground();
    };

    this._generateBackground = function() {
      var bgElem = this._generateUse();
      bgElem.setAttribute('fill', 'url(#' + this.options.backgroundId + ')');
      bgElem.setAttribute('stroke', 'url(#' + this.options.backgroundId + ')');
      bgElem.setAttribute('data-type', 'hex');
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
  },

  /**
   * Wrapper for {@link Action.Grid}. It contains an array of
   * Entity objects (which are standing here) on each place.
   *
   * @constructor
   * @param {?Action.Grid} grid - initial grid which will be wrapped (optional).
   */
  EntitiesGrid: function(grid) {
    /**
     * Raw grid.
     * @type Action.Grid
     */
    this.grid = grid;
    if (!this.grid) this.grid = [];

    /**
     * Add the given entity to place at the given coordinates.
     * Place will be created if it does not exist.
     *
     * @param {Action.Coordinates} coords - the entity will be placed here.
     * @param {Action.Entity} entity - the entity itself.
     */
    this.add = function(coords, entity) {
      var self = this;
      entity.hexes(coords).forEach(function(place) {
        var x = place[0], y = place[1];
        if (typeof self.grid[x] === 'undefined') self.grid[x] = [];
        if (typeof self.grid[x][y] === 'undefined') self.grid[x][y] = [];
        self.grid[x][y].push(entity);
      });
    };

    var self = this;
    var remove_from_place = function(coords, entity) {
      var x = coords[0], y = coords[1];
      if (!(self.grid[x] && self.grid[x][y])) return false;
      var grid_index = self.grid[x][y].indexOf(entity);
      if (grid_index < 0) return false;
      self.grid[x][y].splice(grid_index, 1);
      return true;
    };

    /**
     * Remove the given entity from place at the given coordinates.
     *
     * @param {Action.Coordinates} coords - the entity will be placed here.
     * @param {Action.Entity} entity - the entity itself.
     * @returns {boolean} whether the entity is removed. Usually "false" means
     *   there is no such entity at the place.
     */
    this.remove = function(coords, entity) {
      var success;
      entity.hexes(coords).forEach(function(place) {
        if (remove_from_place(place, entity) && (success !== false))
          success = true;
        else
          success = false;
      });
      return success;
    };

    /**
     * @param {Action.Coordinates} coords - place from which you want to get
     *   entities.
     * @returns {Array<Action.Entity>} all the entities from the given place.
     */
    this.get = function(coords) {
      var x = coords[0], y = coords[1];
      return (this.grid[x] ? this.grid[x][y] : []) || [];
    };
  }
};

/**
 * Generator of action for Display. It builds and manages hexagonal grid and
 * things which are placed on it.
 *
 * @param {object} env - environment variables
 * @param {string} env.area - container element.
 *   All of the action's elements will be placed here.
 * @param {Messenger} env.io - event-driven way to communicate with back-end.
 * @param {Array<function>} env.scripts - array with functions.
 *   They are expected to modify and extend action process.
 *   They will be executed right after generation of the standard markup.
 *   Following arguments will be passed: <br>
 *   "env", "data" - the same variables which you passed to this generator.<br>
 *   "essence" - see {@link Action.Essence}.
 * @param {object} data - information about the action.
 * @param {object} data.subject - description of the action.
 * @param {number} data.subject.hex_size - relative size of hexagons
 *   used by the action.
 *   It is distance from its center to its vertices.
 * @param {object} data.subject.entities_index - object which contains
 *   entities' identificators as keys and their coordinates (Action.Coordinates)
 *   of central points as values.
 * @param {string} data.subject.dependencies - SVG markup.
 *   It will be inserted into the "defs" tag.
 * @param {Action.Grid} data.subject.landscape - description of a landscape
 *   where the action takes place.
 *   Places format: <br>{ g: ground, e: [entity, ...] }.
 *   "ground" and "entity" are objects which represent either ground or entity
 *   which are placed on the place.
 *   <br><br>
 *   Both ground and entity objects must contain properties:
 *   "svg_id" (string) - id of the element which is visualization of the object.
 *      This element must be placed inside the SVG "defs" element,
 *      it will be used to show the object to user through
 *      the "use" SVG element.
 *   <br><br>
 *   Entity object must also contain "id" and "hexes" properties.
 *   See {@link Action.Entity} for their description.
 * @see Display
 */
Action.Generator = function(env, data) {
  var wrapper = env.area.appendChild(document.createElement('div'));
  wrapper.setAttribute('id', 'field');
  var field = wrapper.appendChild(document.createElementNS(NS.SVG, 'svg'));
  var defs = field.appendChild(document.createElementNS(NS.SVG, 'defs'));

  var length = function(x) { return x.length };
  var cols = data.subject.landscape.length;
  var rows = _.max(data.subject.landscape, length).length;
  var hex = new Action.Hex(data.subject.hex_size);
  var hexes = [], entities = {}, entities_grid = new Action.EntitiesGrid();
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
    var place = Action.HexGrid.coords2px(coordinates, hex);
    options = {
      backgroundId: (options.g ? options.g.svg_id : '' ),
      backgroundParentElem: hexesElem,
      templateId: 'hex'
    };
    var svgHex = new Action.SVGHex(place, options);
    svgHex.coordinates = coordinates;
    svgHex.generate();
    var x = coordinates[0], y = coordinates[1];
    if (typeof hexes[x] === 'undefined') hexes[x] = [];
    hexes[x][y] = svgHex;
  };

  var addEntity = function(entity_data, coords) {
    var center_coords = data.subject.entities_index[entity_data.id];
    var entity;
    if (entities[entity_data.id]) {
      entity = entities[entity_data.id];
    }
    else {
      entity = new Action.Entity(_.extend(entity_data, {
        place: center_coords,
        hex: hex
      }));
      entities[entity_data.id] = entity;
      entitiesElem.appendChild(entity.elem);
      entities_grid.add(center_coords, entity);
    }
    return entity;
  };

  var scale = function() {
    width = Action.HexGrid.width(cols, hex);
    height = Action.HexGrid.height(rows, hex);
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

  /**
   * Some information about action markup which is generated in process of
   * ActionGenerator. It also triggers some action-related events.
   * It can be used by scripts to extend or modify action.
   *
   * @interface Action.Essence
   * @mixes Events
   * @fires ActionEssence#event:hoverHex
   * @fires ActionEssence#event:focusChange
   * @property {Element} field - the "svg" element which contains markup of the
   *   action
   * @property {number} cols - number of columns in the grid
   * @property {number} rows - number of rows in the grid
   * @property {Action.Hex} hex - object which is geometric description
   *   of hexagons of the grid
   * @property {number} width - width of the grid
   * @property {number} height - height of the grid
   * @property {SVGElement} hexesElem - container for elements which shows hexes
   * @property {SVGElement} entitiesElem - container for elements which shows
   *   entities
   * @property {Action.Grid<Action.SVGHex>} hexes - grid containing objects
   *   which represent individual hexagons.
   * @property {Action.EntitiesGrid} entities_grid - grid which contains an
   *   array of Entity objects (which are standing here) on each place.
   * @property {object<Action.Entity>} entities - object with "key => value"
   *   pairs, where "value" is an Entity object and "key" is its id.
   * @property {?Action.Entity} focused - current focused entity.
   *   See {@link ActionEssence#event:focusChange}
   * @property {?Action.Coordinates} hovered_hex - hexagon which is hovered
   *   by player's pointer now.
   *   See {@link ActionEssence#event:hoverHex}
   */
  var essence = Events.addEventsTo({
    field: field, cols: cols, rows: rows, width: width, height: height,
    hexesElem: hexesElem, entitiesElem: entitiesElem, hexes: hexes,
    entities: entities, entities_grid: entities_grid, hex: hex
  });
  var BindActionListeners = function() {
    essence.hovered_hex = null, essence.focused = null;

    var getHoveredHex = function(event) {
      var svg_position = field.getBoundingClientRect();
      return Action.HexGrid.px2coords(
        [event.pageX - svg_position.left, event.pageY - svg_position.top],
        hex);
    }
    var hexesEqual = function(first, sec) {
      if (first && sec) return (first[0] == sec[0]) && (first[1] == sec[1]);
      else return first == sec;
    };

    field.addEventListener('mousemove', function(event) {
      var now = getHoveredHex(event);
      var now_exist = hexes[now[0]] && hexes[now[0]][now[1]];
      var was = essence.hovered_hex;
      essence.hovered_hex = (now_exist ? now : null);
      if (!hexesEqual(was, essence.hovered_hex)) {
        /**
         * A hexagon is hovered by the player's pointer.
         *
         * @event ActionEssence#event:hoverHex
         * @type object
         * @property {(Action.Coordinates|null)} was - previous hovered hexagon
         * @property {(Action.Coordinates|null)} now - the hexagon which is just
         *   hovered.
         */
        essence.happen('hoverHex', { was: was, now: essence.hovered_hex });
      }
    });

    field.addEventListener('click', function(event) {
      var id = event.target.getAttribute('data-entity_id');
      var was = essence.focused;
      essence.focused = essence.entities[id] || null;
      if (was != essence.focused) {
        /**
         * An entity is focused (selected) by the player. Usually it means that
         * all of the player's orders will be applied to this entity.
         *
         * @event ActionEssence#event:focusChange
         * @type object
         * @property {(Action.Coordinates|null)} was - entity which have just
         *   lost focus.
         * @property {(Action.Coordinates|null)} now - entity which is just
         *   hovered.
         */
        essence.happen('focusChange', { was: was, now: essence.focused });
      }
    });

    field.addEventListener('contextmenu', function(event) {
      event.preventDefault();
    });
  };

  BindActionListeners();
  if (env.scripts) env.scripts.forEach(function(script) {
    script(env, data, essence);
  });
}

/**
 * Script for Action.Generator which highlights some kinds of hexagons in some
 * cases.
 *
 * @see Action.Generator
 */
function HighlightHexes(env, _data, essence) {
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
  essence.on('focusChange', function(inf) {
    if (inf.now && inf.now.hexes) focusedHighlight.change(inf.now.hexes());
  });
  if (env) env.io.on('move', function(inf) {
    var focused = essence.entities[inf.entity_id];
    if (focused && inf.to) focusedHighlight.change(focused.hexes(inf.to));
  });
}

/**
 * Script for Action.Generator which handles interaction request from player.
 * It means that it decides what does player want to do when he presses right
 * mouse button (by default) and does it.
 *
 * @see Action.Generator
 */
function PlayerInteract(env, _data, essence) {
  essence.field.addEventListener('contextmenu', function() {
    var hovered_hex = essence.hovered_hex, focused = essence.focused;
    if (focused && focused.id && hovered_hex) {
      env.io.happen('move_request', { entity_id: focused.id, to: hovered_hex });
    }
  });
  // The code below needs some defence.
  env.io.on('move', function(inf) {
    var entity = essence.entities[inf.entity_id];
    if (!(entity && inf.to)) return;
    var prev_coords = entity.coordinates;
    essence.entities_grid.remove(prev_coords, entity);
    essence.entities_grid.add(inf.to, entity);
    entity.move(inf.to);
  });
}
