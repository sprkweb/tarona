describe('PlayerInteract', function() {
  var essence, env, entity, entity2, ev, data;

  var realMovement, realEntityInteraction;
  beforeAll(function() {
    realMovement = PlayerInteract.Movement;
    realEntityInteraction = PlayerInteract.EntityInteraction;
  });
  afterAll(function() {
    PlayerInteract.Movement = realMovement;
    PlayerInteract.EntityInteraction = realEntityInteraction;
  });

  beforeEach(function() {
    PlayerInteract.EntityInteraction = jasmine.createSpy();
    PlayerInteract.Movement = jasmine.createSpy();
    entity = {
      id: 'deadbeef',
      coordinates: [3, 2],
      move: jasmine.createSpy('move')
    };
    entity2 = { coordinates: [4, 4] };
    essence = {
      field: {
        addEventListener: jasmine.createSpy('field#addEventListener'),
        removeEventListener: jasmine.createSpy('field#addEventListener'),
      },
      hovered_hex: [4, 4],
      focused: entity,
      entities_grid: {
        add: jasmine.createSpy('entities_grid#add'),
        remove: jasmine.createSpy('entities_grid#remove')
      },
      entities: { deadbeef: entity, enemy: entity2 }
    };
    env = {
      io: {
        happen: jasmine.createSpy('io#happen'),
        on: jasmine.createSpy('io#on'),
        remove_listener: jasmine.createSpy('io#remove_listener')
      },
      display: Events.addEventsTo({}),
      keybindings: { bind: jasmine.createSpy('keybindings#bind') }
    };
    ev = {
      target: document.createElement('div')
    };
    data = {};
    PlayerInteract(env, data, essence);
  });

  it('requests movement to hovered hex when entity is focused', function() {
    var listener = env.keybindings.bind.calls.argsFor(0);
    expect(listener.length).toEqual(3);
    expect(listener[0]).toEqual(essence.field);
    expect(listener[1]).toEqual('interact:press');
    listener[2](ev);
    expect(PlayerInteract.Movement).toHaveBeenCalledWith(
      env, data, essence.focused, essence.hovered_hex);
    expect(PlayerInteract.EntityInteraction).not.toHaveBeenCalled();
  });

  it('requests entity interaction when entity is hovered', function() {
    ev.target.setAttribute('data-entity_id', 'enemy');
    var listener = env.keybindings.bind.calls.argsFor(0);
    listener[2](ev);
    expect(PlayerInteract.EntityInteraction).toHaveBeenCalledWith(
      env, data, essence.focused, entity2);
    expect(PlayerInteract.Movement).not.toHaveBeenCalled();
  });

  it('does nothing when the focused entity is hovered', function() {
    ev.target.setAttribute('data-entity_id', 'deadbeef');
    var listener = env.keybindings.bind.calls.argsFor(0);
    listener[2](ev);
    expect(PlayerInteract.EntityInteraction).not.toHaveBeenCalled();
    expect(PlayerInteract.Movement).not.toHaveBeenCalled();
  });

  it('does nothing when entity is not focused', function() {
    essence.focused = null;
    var listener = env.keybindings.bind.calls.argsFor(0);
    ev.target.setAttribute('data-entity_id', 'enemy');
    listener[2](ev);
    expect(PlayerInteract.EntityInteraction).not.toHaveBeenCalled();
    expect(PlayerInteract.Movement).not.toHaveBeenCalled();
  });

  it('does nothing when nothing is hovered', function() {
    essence.hovered_hex = null;
    var listener = env.keybindings.bind.calls.argsFor(0);
    listener[2](ev);
    expect(PlayerInteract.EntityInteraction).not.toHaveBeenCalled();
    expect(PlayerInteract.Movement).not.toHaveBeenCalled();
  });

  it('does nothing after act is ended', function() {
    expect(essence.field.removeEventListener).not.toHaveBeenCalled();
    env.display.happen('before_act');
    var added = essence.field.addEventListener.calls.argsFor(0);
    var removed = essence.field.removeEventListener.calls.argsFor(0);
    expect(added).toEqual(removed);
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
});
