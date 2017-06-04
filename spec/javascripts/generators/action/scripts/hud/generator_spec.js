describe('HUD.Generator', function() {
  var realEntityInfo;
  beforeAll(function() {
    realEntityInfo = HUD.EntityInfo;
  });
  afterAll(function() {
    HUD.EntityInfo = realEntityInfo;
  });

  var env, data, essence, area, parts;
  beforeEach(function() {
    area = document.createElement('div');
    env = { area: area };
    data = {};
    essence = {};
    parts = ['EntityInfo'];
    parts.forEach(function(part) {
      var elem = document.createElement('div');
      elem.innerHTML = part;
      spyOn(HUD, part).and.returnValue(elem);
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

  it('appends returned values from parts to the container', function() {
    var container = area.childNodes[0];
    parts.forEach(function(part, num) {
      expect(container.childNodes[num].innerHTML).toEqual(part);
    });
  });
});
