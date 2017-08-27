describe('HUD.Generator', function() {
  var realParts;
  beforeAll(function() {
    realParts = HUD.PARTS;
  });
  afterAll(function() {
    HUD.PARTS = realParts;
  });

  var area;
  beforeEach(function() {
    area = document.createElement('div');
    HUD.PARTS = [
      function() {
        var elem = document.createElement('div');
        elem.innerHTML = 'Content';
        return elem;
      },
      function() {
        return 'foo';
      }
    ];
    HUD.Generator({ area: area }, {}, {});
  });

  it('creates HUD container', function() {
    var container = area.childNodes[0];
    expect(container).not.toBeNull();
    expect(container.tagName).toEqual('DIV');
    expect(container.className).toEqual('hud');
  });

  it('appends returned Elements from parts to the container', function() {
    var container = area.childNodes[0];
    expect(container.childNodes.length).toEqual(1);
    expect(container.childNodes[0].innerHTML).toEqual('Content');
  });
});
