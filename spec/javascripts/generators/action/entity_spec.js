describe('Action.Entity', function() {
  var entity, options;
  beforeEach(function() {
    options = {
      id: 'me',
      svg_id: 'man',
      hex: new Action.Hex(15),
      place: [10, 15],
      hexes: { even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 1]] }
    };
    entity = new Action.Entity(options);
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
});
