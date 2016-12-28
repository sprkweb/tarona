describe('Action.SVGHex', function() {
  var place, options, hex, container;
  beforeEach(function() {
    place = [23, 17.4];
    options = {
      templateId: 'hex', backgroundId: 'red', backgroundParentElem: container
    };
    hex = new Action.SVGHex(place, options);
  });

  it('saves its place', function() {
    expect(hex.place).toEqual(place);
  });

  it('saves its options', function() {
    expect(hex.options).toEqual(options);
  });

  describe('#generate', function() {
    var hex, container;
    beforeAll(function() {
      container = document.createElement('svg');
      hex = new Action.SVGHex(place, options);
      hex.options.backgroundParentElem = container;
      hex.generate();
    });

    it('saves its element as an instance variable', function() {
      var hex_el = container.getElementsByTagName('use')[0];
      expect(hex_el).toBe(hex.backgroundElem);
    });

    it('generates the "use" element for hex at its place', function() {
      var hex_el = hex.backgroundElem;
      expect(typeof hex_el).toEqual('object');
      expect(hex_el.getAttribute('x')).toEqual('23');
      expect(hex_el.getAttribute('y')).toEqual('17.4');
    });

    it('uses given visualization', function() {
      var hex_el = hex.backgroundElem;
      expect(hex_el.getAttribute('href')).toEqual('#hex');
      expect(hex_el.getAttribute('fill')).toEqual('url(#red)');
      expect(hex_el.getAttribute('stroke')).toEqual('url(#red)');
    });

    it('sets data-type attribute', function() {
      expect(hex.backgroundElem.getAttribute('data-type')).toEqual('hex');
    });
  });
});
