describe('HUD.EntityInfo', function() {
  var env, data, essence, area, container, entity, listener;
  beforeEach(function() {
    area = document.createElement('div');
    env = {
      area: area,
      io: Events.addEventsTo({}),
      display: Events.addEventsTo({})
    };
    data = {
      subject: { i18n: { entity_info: { health: 'bar', energy: 'baz' } } }
    };
    essence = Events.addEventsTo({});
    entity = { id: 'foo' };
    listener = jasmine.createSpy();
    container = HUD.EntityInfo(env, data, essence);
  });

  it('creates container', function() {
    expect(container.tagName).toEqual('DIV');
    expect(container.className).toEqual('info_list');
  });

  it('requests information about focused entity', function() {
    env.io.on('entity_info_request', listener);
    essence.happen('focusChange', { now: entity });
    expect(listener).toHaveBeenCalledWith({ id: entity.id });
  });

  var spanWithText = function(elem, text) {
    return !!((elem.tagName == 'SPAN') && (elem.innerHTML = text));
  };

  it('shows entity information when it is received', function() {
    var params = { hp: 2, max_hp: 3, energy: 5, max_energy: 8, name: 'abc' };
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children.length).toEqual(3);
    expect(children[0].tagName).toEqual('P');
    expect(children[0].innerHTML).toEqual('abc');
    expect(children[1].tagName).toEqual('P');
    expect(spanWithText(children[1].childNodes[0], 'bar')).toBe(true);
    expect(spanWithText(children[1].childNodes[1], '2/3')).toBe(true);
    expect(children[2].tagName).toEqual('P');
    expect(spanWithText(children[2].childNodes[0], 'baz')).toBe(true);
    expect(spanWithText(children[2].childNodes[1], '5/8')).toBe(true);
  });

  it('shows only received information', function() {
    var params = { hp: 2, energy: 1, max_energy: 9, name: 'cba' };
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children.length).toEqual(2);
    expect(children[0].tagName).toEqual('P');
    expect(children[0].innerHTML).toEqual('cba');
    expect(children[1].tagName).toEqual('P');
    expect(spanWithText(children[1].childNodes[0], 'baz')).toBe(true);
    expect(spanWithText(children[1].childNodes[1], '1/9')).toBe(true);
  });

  it('cleans container before new information is shown', function() {
    var params = { hp: 2, max_hp: 3, energy: 5, max_energy: 8 };
    env.io.happen('entity_info_show', params);
    env.io.happen('entity_info_show', {});
    expect(container.childNodes.length).toEqual(0);
  });

  it('does not request information after act is ended', function() {
    env.display.happen('before_act');
    env.io.on('entity_info_request', listener);
    essence.happen('focusChange', { now: entity });
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not show information after act is ended', function() {
    env.display.happen('before_act');
    var params = { hp: 2, max_hp: 3, energy: 5, max_energy: 8 };
    env.io.happen('entity_info_show', params);
    expect(container.childNodes.length).toEqual(0);
  });
});
