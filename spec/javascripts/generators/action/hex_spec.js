describe('Action.Hex', function() {
  var hex, hex2;
  beforeEach(function() {
    hex = new Action.Hex(10);
    hex2 = new Action.Hex(15);
  });

  it('saves its size', function() {
    expect(hex.size).toEqual(10);
    expect(hex2.size).toEqual(15);
  });

  it('calculates the height of the hexagon', function() {
    expect(hex.height).toEqual(20);
    expect(hex2.height).toEqual(30);
  });

  it('calculates the width of the hexagon', function() {
    expect(hex.width).toBeCloseTo(17.32, 2);
    expect(hex2.width).toBeCloseTo(25.98, 2);
  });

  it('calculates the vertical distance between hexes in a pattern', function() {
    expect(hex.verticalSpace).toEqual(15);
    expect(hex2.verticalSpace).toEqual(22.5);
  });

  describe('#generateLine', function() {
    it('generates SVG border line of hex for the "d" attribute', function() {
      expect(hex.generateLine({ x: 0, y: 0 })).toEqual(
        'M 8.6602540378 5 L 0 10 L -8.6602540378 5 L -8.6602540378 -5 L 0 -10 L 8.6602540378 -5 Z');
      expect(hex2.generateLine({ x: 15, y: 25 })).toEqual(
        'M 27.9903810568 32.5 L 15 40 L 2.0096189432 32.5 L 2.0096189432 17.5 L 15 10 L 27.9903810568 17.5 Z');
    });
  });
});
