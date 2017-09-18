describe('Action.Entity', function() {
  var entity, parentElem, options;
  beforeEach(function() {
    options = {
      id: 'me',
      svg_id: 'man',
      hex: new Action.Hex(15),
      place: [10, 15],
      hexes: { even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 1]] }
    };
    parentElem = document.createElement('div');
    entity = new Action.Entity(options);
    parentElem.appendChild(entity.elem);
  });

  it('saves its id', function() {
    expect(entity.id).toBe(options.id);
  });

  it('saves its place', function() {
    expect(entity.coordinates).toBe(options.place);
  });

  it('saves given hex', function() {
    expect(entity.hex).toBe(options.hex);
  });

  it('saves given options', function() {
    expect(entity.options).toBe(options);
  });

  describe('element', function() {
    it('is saved as an "elem" attribute', function() {
      expect(entity.elem instanceof SVGUseElement).toBeTruthy();
    });

    it('has data-type=entity attribute', function() {
      expect(entity.elem.getAttribute('data-type')).toEqual('entity');
    });

    it('has data-entity_id attribute', function() {
      expect(entity.elem.getAttribute('data-entity_id')).toEqual(entity.id);
    });

    it('uses given template', function() {
      expect(entity.elem.getAttribute('href')).toEqual('#man');
    });

    it('is placed accordingly to its coordinates', function() {
      expect(entity.elem.getAttribute('x')).toEqual('285.7883832488647');
      expect(entity.elem.getAttribute('y')).toEqual('352.5');
    });
  });

  describe('#move', function() {
    var new_place;
    beforeEach(function() {
      new_place = [5, 6];
    });

    it('changes entity\'s coordinates', function() {
      entity.move(new_place);
      expect(entity.coordinates).toEqual(new_place);
    });

    it('moves entity\'s element to the new place', function() {
      entity.move(new_place);
      expect(entity.elem.getAttribute('x')).toEqual('142.89419162443235');
      expect(entity.elem.getAttribute('y')).toEqual('150');
    });
  });

  describe('#remove', function() {
    it('removes entity\'s element', function() {
      expect(parentElem.childNodes.length).toEqual(1);
      entity.remove();
      expect(parentElem.childNodes.length).toEqual(0);
    });
  });

  describe('#changePlace', function() {
    var new_position;
    beforeEach(function() {
      new_position = [50, 65];
    });

    it('does not changes entity\'s coordinates', function() {
      entity.changePlace(new_position);
      expect(entity.coordinates).toEqual(options.place);
    });

    it('moves entity\'s element to the given place', function() {
      entity.changePlace(new_position);
      expect(entity.elem.getAttribute('x')).toEqual('50');
      expect(entity.elem.getAttribute('y')).toEqual('65');
    });
  });

  it('can change its template with the changeTemplate method', function() {
    var new_look = 'skeleton';
    entity.changeTemplate(new_look);
    expect(entity.elem.getAttribute('href')).toEqual('#skeleton');
  });

  describe('#hexes', function() {
    it('returns hexes which it takes when it stands on odd row', function() {
      expect(entity.hexes()).toEqual([[10, 15], [11, 16]]);
    });

    it('returns hexes which it takes when it stands on even row', function() {
      entity.move([5, 6]);
      expect(entity.hexes()).toEqual([[5, 6], [5, 7]]);
    });

    it('can use given coordinates instead of current', function() {
      expect(entity.hexes([3, 2])).toEqual([[3, 2], [3, 3]]);
    });
  });

  describe('#distance', function() {
    var entity2, entity3, entity4;
    beforeEach(function() {
      entity2 = new Action.Entity(_.extend(_.clone(options), {
        place: [3, 4],
        hexes: {
          even_row: [[0, 0], [0, -1], [1, -2]],
          odd_row: [[0, 0], [1, -1], [1, -2]]
        }
      }));
      entity3 = new Action.Entity(_.extend(_.clone(options), {
        place: [3, 3],
        hexes: {
          even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 1]]
        }
      }));
      entity4 = new Action.Entity(_.extend(_.clone(options), {
        place: [6, 0],
        hexes: {
          even_row: [[0, 0], [-1, 0]], odd_row: [[0, 0], [-1, 0]]
        }
      }));
    });

    it('returns distance between two nearest parts of entities', function() {
      expect(entity2.distance(entity4)).toEqual(2);
    });

    it('returns 1 when they stand alongside', function() {
      entity3.coordinates = [2, 2];
      expect(entity2.distance(entity3)).toEqual(1);
    });

    it('returns 0 when entities are on the same place', function() {
      expect(entity2.distance(entity3)).toEqual(0);
    });
  });
});
