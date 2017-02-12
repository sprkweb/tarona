describe('HighlightHexes', function() {
  describe('under focused entities', function() {
    var essence, entity, entity2, io;
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
      entity = { hexes: function() { return [[1, 1], [1, 2], [1, 0]]; } };
      entity2 = { hexes: function() { return [[2, 1], [2, 2], [3, 1]]; } };
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
      HighlightHexes({ io: io }, null, essence);
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
      entity.hexes = jasmine.createSpy('entity#hexes');
      io.happen('move', { entity_id: 'cat', to: [0, 0] });
      expect(entity.hexes).toHaveBeenCalledWith([0, 0]);
    });
  });
});
