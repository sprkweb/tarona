describe('MoveEntity', function() {
  var essence, env, entity, data;

  beforeEach(function() {
    entity = {
      id: 'deadbeef',
      coordinates: [3, 2],
      move: jasmine.createSpy('move'),
      remove: jasmine.createSpy('remove')
    };
    essence = {
      entities_grid: {
        add: jasmine.createSpy('entities_grid#add'),
        remove: jasmine.createSpy('entities_grid#remove')
      },
      entities: { deadbeef: entity }
    };
    env = {
      display: Events.addEventsTo({}),
      io: {
        happen: jasmine.createSpy('io#happen'),
        on: jasmine.createSpy('io#on'),
        remove_listener: jasmine.createSpy('io#remove_listener')
      }
    };
    data = {};
    MoveEntity(env, data, essence);
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

  it('does not move entity after act is ended', function() {
    expect(env.io.remove_listener).not.toHaveBeenCalled();
    env.display.happen('before_act');
    var added = env.io.on.calls.argsFor(0);
    var removed = env.io.remove_listener.calls.argsFor(0);
    expect(added).toEqual(removed);
  });

  it('removes entity when it is ordered from io', function() {
    var listener = env.io.on.calls.argsFor(1);
    expect(listener[0]).toEqual('remove');
    listener[1]({ entity_id: 'deadbeef' });
    expect(essence.entities_grid.remove).toHaveBeenCalledWith([3, 2], entity);
    expect(entity.remove).toHaveBeenCalled();
  });

  it('does not remove entity without entity', function() {
    var listener = env.io.on.calls.argsFor(1);
    listener[1]({ entity_id: 'livebeef' });
    expect(essence.entities_grid.remove).not.toHaveBeenCalled();
    expect(entity.remove).not.toHaveBeenCalled();
  });

  it('does not remove entity after act is ended', function() {
    expect(env.io.remove_listener).not.toHaveBeenCalled();
    env.display.happen('before_act');
    var added = env.io.on.calls.argsFor(1);
    var removed = env.io.remove_listener.calls.argsFor(1);
    expect(added).toEqual(removed);
  });
});
