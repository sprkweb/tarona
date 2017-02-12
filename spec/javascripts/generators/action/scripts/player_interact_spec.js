describe('PlayerInteract', function() {
  var fakeRMBClick = function(target) {
    var click = document.createEvent('CustomEvent');
    click.initEvent('contextmenu', true, false, null);
    target.dispatchEvent(click);
  };

  var essence, env, entity;
  beforeEach(function() {
    entity = { coordinates: [3, 2], move: jasmine.createSpy('move') };
    essence = {
      field: { addEventListener: jasmine.createSpy('field#addEventListener') },
      hovered_hex: [3, 2],
      focused: { id: 'man' },
      entities_grid: {
        add: jasmine.createSpy('entities_grid#add'),
        remove: jasmine.createSpy('entities_grid#remove')
      },
      entities: { deadbeef: entity }
    };
    env = {
      io: {
        happen: jasmine.createSpy('io#happen'),
        on: jasmine.createSpy('io#on')
      }
    };
    PlayerInteract(env, null, essence);
  });

  it('requests movement to hovered hex when entity is focused', function() {
    var listener = essence.field.addEventListener.calls.argsFor(0);
    expect(listener[0]).toEqual('contextmenu');
    listener[1]();
    expect(env.io.happen).toHaveBeenCalledWith('move_request',
      { entity_id: essence.focused.id, to: essence.hovered_hex });
  });

  it('does not request movement when entity is not focused', function() {
    essence.focused = null;
    var listener = essence.field.addEventListener.calls.argsFor(0);
    listener[1]();
    expect(env.io.happen).not.toHaveBeenCalled();
  });

  it('does not request movement when hexagon is not hovered', function() {
    essence.hovered_hex = null;
    var listener = essence.field.addEventListener.calls.argsFor(0);
    listener[1]();
    expect(env.io.happen).not.toHaveBeenCalled();
  });

  it('moves entity when it is ordered from io', function() {
    var listener = env.io.on.calls.argsFor(0);
    expect(listener[0]).toEqual('move');
    listener[1]({ to: [5, 6], entity_id: 'deadbeef' });
    expect(essence.entities_grid.remove).toHaveBeenCalledWith([3, 2], entity);
    expect(essence.entities_grid.add).toHaveBeenCalledWith([5, 6], entity);
    expect(entity.move).toHaveBeenCalledWith([5, 6]);
  });

  it('does not move entity without target', function() {
    var listener = env.io.on.calls.argsFor(0);
    listener[1]({ entity_id: 'deadbeef' });
    expect(essence.entities_grid.remove).not.toHaveBeenCalled();
    expect(essence.entities_grid.add).not.toHaveBeenCalled();
    expect(entity.move).not.toHaveBeenCalled();
  });

  it('does not move entity without entity', function() {
    var listener = env.io.on.calls.argsFor(0);
    listener[1]({ to: [5, 6], entity_id: 'livebeef' });
    expect(essence.entities_grid.remove).not.toHaveBeenCalled();
    expect(essence.entities_grid.add).not.toHaveBeenCalled();
    expect(entity.move).not.toHaveBeenCalled();
  });
});
