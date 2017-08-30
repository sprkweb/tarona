describe('HUD.EntityInfo', function() {
  var env, data, essence, area, container, entity, listener, params;
  beforeEach(function() {
    area = document.createElement('div');
    env = {
      area: area,
      io: Events.addEventsTo({}),
      display: Events.addEventsTo({})
    };
    data = {
      subject: {
        i18n: { 'entity_info/health': 'bar', 'entity_info/energy': 'baz' }
      }
    };
    entity = { id: 'foo' };
    essence = Events.addEventsTo({ focused: entity });
    listener = jasmine.createSpy();
    container = HUD.EntityInfo(env, data, essence);
    params = { hp: 2, max_hp: 3, energy: 5, max_energy: 8, name: 'abc' };
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

  it('requests information again when there is new tick', function() {
    env.io.on('entity_info_request', listener);
    env.io.happen('tick_start');
    expect(listener).toHaveBeenCalledWith({ id: entity.id });
  });

  it('does not request information when entity is not focused', function() {
    env.io.on('entity_info_request', listener);
    essence.focused = null;
    env.io.happen('tick_start');
    essence.happen('focusChange', { now: null });
    expect(listener).not.toHaveBeenCalled();
  });

  var spanWithText = function(elem, text) {
    return !!((elem.tagName == 'SPAN') && (elem.innerHTML == text));
  };

  it('shows entity information when it is received', function() {
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children.length).toEqual(3);
  });

  it('shows name of the entity', function() {
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children[0].tagName).toEqual('P');
    expect(children[0].innerHTML).toEqual('abc');
  });

  it('shows HP of the entity', function() {
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children[1].tagName).toEqual('P');
    expect(spanWithText(children[1].childNodes[0], 'bar: ')).toBe(true);
    expect(spanWithText(children[1].childNodes[1], '2/3')).toBe(true);
  });

  it('shows energy of the entity', function() {
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children[2].tagName).toEqual('P');
    expect(spanWithText(children[2].childNodes[0], 'baz: ')).toBe(true);
    expect(spanWithText(children[2].childNodes[1], '5/8')).toBe(true);
  });

  it('shows only received information', function() {
    params = { hp: 2, energy: 1, max_energy: 9, name: 'cba' };
    env.io.happen('entity_info_show', params);
    var children = container.childNodes;
    expect(children.length).toEqual(2);
    expect(children[0].tagName).toEqual('P');
    expect(children[0].innerHTML).toEqual('cba');
    expect(children[1].tagName).toEqual('P');
    expect(spanWithText(children[1].childNodes[0], 'baz: ')).toBe(true);
    expect(spanWithText(children[1].childNodes[1], '1/9')).toBe(true);
  });

  it('cleans container before new information is shown', function() {
    params = { hp: 2, max_hp: 3, energy: 5, max_energy: 8 };
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
