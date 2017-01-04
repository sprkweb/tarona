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
    var eachHex = function(func) {
      essence.hexes.forEach(function(col, colNum) {
        col.forEach(function(hex, rowNum) {
          func([colNum, rowNum], hex);
        });
      });
    };
    var checkHexes = function(hexes, checkFunc) {
      eachHex(function(coords, hex) {
        if (_.contains(hexes, coords))
          checkFunc(coords, hex);
        else
          expect(hex.backgroundElem.classList.add).not.toHaveBeenCalled();
      });
    };
    var highlightAdded = function(_coords, hex) {
      var classRemove = hex.backgroundElem.classList.remove;
      expect(classRemove).toHaveBeenCalledWith('focused');
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
        if (_.contains(entity.hexes(), coords)) highlightRemoved(null, hex);
      });
      eachHex(function(coords, hex) {
        if (_.contains(entity2.hexes(), coords)) highlightAdded(null, hex);
      });
    });
  });
});
