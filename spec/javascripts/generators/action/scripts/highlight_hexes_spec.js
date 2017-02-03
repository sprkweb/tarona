describe('HighlightHexes', function() {
  describe('under focused entities', function() {
    var essence, entity, entity2;
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
      essence = Events.addEventsTo({
        hexes: [
          [fakeHex(), fakeHex(), fakeHex()],
          [fakeHex(), fakeHex(), fakeHex()],
          [fakeHex(), fakeHex(), fakeHex()],
          [fakeHex(), fakeHex(), fakeHex()]
        ]
      });
      entity = { hexes: function() { return [[1, 1], [1, 2], [1, 0]]; } };
      entity2 = { hexes: function() { return [[2, 1], [2, 2], [3, 1]]; } };
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
    var checkHexes = function(hexes, checkFunc) {
      eachHex(function(coords, hex) {
        if (contains(hexes, coords))
          checkFunc(coords, hex);
        else
          expect(hex.backgroundElem.classList.add).not.toHaveBeenCalled();
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
      HighlightHexes(null, null, essence);
      essence.happen('focusChange', { was: null, now: entity });
      checkHexes(entity.hexes(), highlightAdded);
    });

    it('does not highlight hexes when no entity is focused', function() {
      HighlightHexes(null, null, essence);
      checkHexes([], function() { expect(false).toBeTruthy(); });
    });

    it('deletes highlight from previous focused entity', function() {
      HighlightHexes(null, null, essence);
      essence.happen('focusChange', { was: null, now: entity });
      essence.happen('focusChange', { was: entity, now: null });
      checkHexes(entity.hexes(), highlightRemoved);
    });

    it('moves highlight when another entity is focused', function() {
      HighlightHexes(null, null, essence);
      essence.happen('focusChange', { was: null, now: entity });
      essence.happen('focusChange', { was: entity, now: entity2 });
      eachHex(function(coords, hex) {
        if (contains(entity.hexes(), coords)) highlightRemoved(null, hex);
      });
      eachHex(function(coords, hex) {
        if (contains(entity2.hexes(), coords)) highlightAdded(null, hex);
      });
    });
    
    it('moves highlight when the entity is moved', function() {
      var io = Events.addEventsTo({});
      var previous_hexes = entity.hexes();
      HighlightHexes({ io: io }, null, essence);
      essence.happen('focusChange', { was: null, now: entity });
      io.happen('move');
      eachHex(function(coords, hex) {
        if (contains(previous_hexes, coords)) highlightRemoved(null, hex);
      });
      eachHex(function(coords, hex) {
        if (contains(entity.hexes(), coords)) highlightAdded(null, hex);
      });
    });
  });
});
