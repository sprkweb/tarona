describe('Action.HexGrid', function() {
  var hex, hex2, subj = Action.HexGrid;
  beforeEach(function() {
    hex = new Action.Hex(10);
    hex2 = new Action.Hex(15);
  });

  describe('#coords2px', function() {
    it('can convert hexagonal coordinates to pixels', function() {
      expect(subj.coords2px([0, 1], hex)).toEqual([17.32050807568877, 25]);
      expect(subj.coords2px([1, 2], hex2)).toEqual([38.97114317029973, 60]);
    });
  });

  describe('#px2coords', function() {
    it('can convert pixels to hexagonal coordinates', function() {
      expect(subj.px2coords([17, 26.1], hex)).toEqual([0, 1]);
      expect(subj.px2coords([37.8, 65], hex2)).toEqual([1, 2]);
    });
  });

  describe('#height', function() {
    it('calculates the height of the grid', function() {
      expect(subj.height(2, hex)).toBeCloseTo(35, 2);
      expect(subj.height(3, hex2)).toBeCloseTo(75, 2);
    });
  });

  describe('#width', function() {
    it('calculates the width of the grid', function() {
      expect(subj.width(3, hex)).toBeCloseTo(60.62, 2);
      expect(subj.width(4, hex2)).toBeCloseTo(116.91, 2);
    });
  });

  describe('#distance', function() {
    it('calculate the distance between two hexagons', function() {
      var needed_results = [
        [ [[1, 2], [4, 4]],     4 ],
        [ [[0, 0], [1, 2]],     2 ],
        [ [[135, 5], [135, 5]], 0 ],
        [ [[7, 5], [7, 4]],     1 ],
        [ [[0, 0], [0, 0]],      0 ]
      ];
      needed_results.forEach(function(a) {
        var from = a[0][0], to = a[0][1], result = a[1];
        expect(subj.distance(from, to)).toEqual(result);
      });
    });
  });
});
