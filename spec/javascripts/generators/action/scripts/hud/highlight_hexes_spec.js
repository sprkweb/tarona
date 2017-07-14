describe('HUD.HighlightHexes', function() {
  var essence, entity, entity2, io, display, listener;
  beforeEach(function() {
    var fakeHex = function() {
      return {
        backgroundElem: {
          classList: {
            add: jasmine.createSpy('classList#add'),
            remove: jasmine.createSpy('classList#remove')
          }
        }
      };
    };
    listener = jasmine.createSpy();
    entity = {
      id: 'cat',
      coordinates: [1, 1],
      hexes: function() { return [[1, 1], [1, 2], [1, 0]]; }
    };
    entity2 = {
      id: 'dog',
      coordinates: [2, 2],
      hexes: function() { return [[2, 1], [2, 2], [3, 1]]; }
    };
    essence = Events.addEventsTo({
      hexes: [
        [fakeHex(), fakeHex(), fakeHex()],
        [fakeHex(), fakeHex(), fakeHex()],
        [fakeHex(), fakeHex(), fakeHex()],
        [fakeHex(), fakeHex(), fakeHex()]
      ],
      entities: { cat: entity }
    });
    io = Events.addEventsTo({});
    display = Events.addEventsTo({});
    HUD.HighlightHexes({ io: io, display: display }, null, essence);
  });
  var contains = function(inThisList, coords) {
    return !!(_.find(inThisList, function(arr) {
      return (arr[0] == coords[0]) && (arr[1] == coords[1]);
    }))
  };
  var eachHex = function(func) {
    essence.hexes.forEach(function(col, colNum) {
      col.forEach(function(hex, rowNum) {
        func([colNum, rowNum], hex);
      });
    });
  };
  var checkHexesStrict = function(hexes, checkFunc) {
    eachHex(function(coords, hex) {
      if (contains(hexes, coords))
        checkFunc(coords, hex);
      else
        expect(hex.backgroundElem.classList.add).not.toHaveBeenCalled();
    });
  };
  var checkHexes = function(hexes, checkFunc) {
    eachHex(function(coords, hex) {
      if (contains(hexes, coords)) checkFunc(coords, hex);
    });
  };

  describe('under focused entities', function() {
    var highlightAdded = function(_coords, hex) {
      var classAdd = hex.backgroundElem.classList.add;
      expect(classAdd).toHaveBeenCalledWith('focused');
    };
    var highlightRemoved = function(_coords, hex) {
      var classRemove = hex.backgroundElem.classList.remove;
      expect(classRemove).toHaveBeenCalledWith('focused');
    };

    it('highlight hexes when entity is focused', function() {
      essence.happen('focusChange', { was: null, now: entity });
      checkHexesStrict(entity.hexes(), highlightAdded);
    });

    it('does not highlight hexes when no entity is focused', function() {
      checkHexesStrict([], function() { expect(false).toBeTruthy(); });
    });

    it('deletes highlight from previous focused entity', function() {
      essence.happen('focusChange', { was: null, now: entity });
      essence.happen('focusChange', { was: entity, now: null });
      checkHexesStrict(entity.hexes(), highlightRemoved);
    });

    it('moves highlight when another entity is focused', function() {
      essence.happen('focusChange', { was: null, now: entity });
      essence.happen('focusChange', { was: entity, now: entity2 });
      checkHexes(entity.hexes(), highlightRemoved);
      checkHexes(entity2.hexes(), highlightAdded);
    });

    it('moves highlight when the entity is moved', function() {
      var previous_hexes = entity.hexes();
      essence.happen('focusChange', { was: null, now: entity });
      entity.hexes = function() { return [[0, 0], [1, 1]] };
      io.happen('move', { entity_id: 'cat', to: [0, 0] });
      checkHexes(previous_hexes, highlightRemoved);
      checkHexes(entity.hexes, highlightAdded);
    });

    it('uses entity#hexes when the entity is moved', function() {
      var previous_hexes = entity.hexes();
      essence.happen('focusChange', { was: null, now: entity });
      spyOn(entity, 'hexes').and.callThrough();
      io.happen('move', { entity_id: 'cat', to: [0, 0] });
      expect(entity.hexes).toHaveBeenCalledWith([0, 0]);
    });

    it('does not use entity#hexes when another entity is moved', function() {
      var previous_hexes = entity.hexes();
      essence.happen('focusChange', { was: null, now: entity });
      spyOn(entity, 'hexes').and.callThrough();
      io.happen('move', { entity_id: 'dog', to: [0, 0] });
      expect(entity.hexes).not.toHaveBeenCalled();
    });

    it('does not highlight focused entities after act is ended', function() {
      display.happen('before_act');
      essence.happen('focusChange', { was: null, now: entity });
      checkHexesStrict([], function() { expect(false).toBeTruthy(); });
    });

    it('does not move highlight of focused entities after end', function() {
      essence.happen('focusChange', { was: null, now: entity });
      display.happen('before_act');
      spyOn(entity, 'hexes').and.callThrough();
      io.happen('move', { entity_id: 'cat', to: [0, 0] });
      expect(entity.hexes).not.toHaveBeenCalled();
    });


  });

  describe('around movable entity', function() {
    var reachable = { places: [[[1, 2], null], [[1, 0], [2, 3]]] };
    var highlightAdded = function(_coords, hex) {
      var classAdd = hex.backgroundElem.classList.add;
      expect(classAdd).toHaveBeenCalledWith('reachable');
    };
    var highlightRemoved = function(_coords, hex) {
      var classRemove = hex.backgroundElem.classList.remove;
      expect(classRemove).toHaveBeenCalledWith('reachable');
    };

    it('looks for reachable places when entity is focused', function() {
      essence.focused = entity;
      io.on('movement_potential_request', listener);
      essence.happen('focusChange', { was: null, now: entity });
      expect(listener).toHaveBeenCalledWith({ entity_id: 'cat' });
    });

    it('does nothing when no entity is focused', function() {
      io.on('movement_potential_request', listener);
      essence.happen('focusChange', { was: null, now: null });
      expect(listener).not.toHaveBeenCalled();
    });

    it('highlights reachable places after their list is received', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity.coordinates, reachable: reachable
      });
      checkHexesStrict([[1, 2], [1, 0]], highlightAdded);
    });

    it('does not highlight received places for other entity', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity2.id, from: entity.coordinates, reachable: reachable
      });
      checkHexesStrict([], function() { expect(false).toBeTruthy(); });
    });

    it('does not highlight received places with other center', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity2.coordinates, reachable: reachable
      });
      checkHexesStrict([], function() { expect(false).toBeTruthy(); });
    });

    it('clears highlight when entity loses focus', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity.coordinates, reachable: reachable
      });
      essence.happen('focusChange', { was: entity, now: null });
      checkHexes([[1, 2], [1, 0]], highlightRemoved);
    });

    it('clears highlight when new tick is started', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity.coordinates, reachable: reachable
      });
      io.happen('tick_start');
      checkHexes([[1, 2], [1, 0]], highlightRemoved);
    });

    it('requests new reachable places when new tick is started', function() {
      essence.focused = entity;
      io.on('movement_potential_request', listener);
      io.happen('tick_start');
      expect(listener).toHaveBeenCalledWith({ entity_id: 'cat' });
    });

    it('clears highlight when new entity gets focus', function() {
      essence.focused = entity;
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity.coordinates, reachable: reachable
      });
      essence.happen('focusChange', { was: entity, now: entity2 });
      checkHexes([[1, 2], [1, 0]], highlightRemoved);
    });

    it('requests new reachable places when new entity gets focus', function() {
      essence.focused = entity2;
      io.on('movement_potential_request', listener);
      essence.happen('focusChange', { was: entity, now: entity2 });
      expect(listener).toHaveBeenCalledWith({ entity_id: 'dog' });
    });

    it('does not request reachable places after act is ended', function() {
      essence.focused = entity;
      io.on('movement_potential_request', listener);
      display.happen('before_act');
      essence.happen('focusChange', { was: null, now: entity });
      io.happen('tick_start');
      expect(listener).not.toHaveBeenCalled();
    });

    it('does not highlight places after act is ended', function() {
      essence.focused = entity;
      display.happen('before_act');
      io.happen('movement_potential_show', {
        entity_id: entity.id, from: entity.coordinates, reachable: reachable
      });
      checkHexesStrict([], function() { expect(false).toBeTruthy(); });
    });
  });
});
