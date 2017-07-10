describe('HUD.Generator', function() {
  var realEntityInfo, realHighlightHexes;
  beforeAll(function() {
    realEntityInfo = HUD.EntityInfo;
    realHighlightHexes = HUD.HighlightHexes;
  });
  afterAll(function() {
    HUD.EntityInfo = realEntityInfo;
    HUD.HighlightHexes = realHighlightHexes;
  });

  var env, data, essence, area, parts, partsWithElems, partsWithoutElems;
  beforeEach(function() {
    area = document.createElement('div');
    env = { area: area };
    data = {};
    essence = {};
    partsWithElems = ['EntityInfo'];
    partsWithoutElems = ['HighlightHexes'];
    parts = partsWithoutElems.concat(partsWithElems);
    partsWithElems.forEach(function(part) {
      var elem = document.createElement('div');
      elem.innerHTML = part;
      spyOn(HUD, part).and.returnValue(elem);
    });
    partsWithoutElems.forEach(function(part) {
      spyOn(HUD, part).and.returnValue('foo');
    });
    HUD.Generator(env, data, essence);
  });

  it('creates HUD container', function() {
    var container = area.childNodes[0];
    expect(container).not.toBeNull();
    expect(container.tagName).toEqual('DIV');
    expect(container.className).toEqual('hud');
  });

  it('calls its parts', function() {
    parts.forEach(function(part) {
      expect(HUD[part]).toHaveBeenCalledWith(env, data, essence);
    });
  });

  it('appends returned Elements from parts to the container', function() {
    var container = area.childNodes[0];
    expect(partsWithElems.length).toEqual(container.childNodes.length)
    partsWithElems.forEach(function(part, num) {
      expect(container.childNodes[num].innerHTML).toEqual(part);
    });
  });
});
