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
      entities: { deadbeef: entity, enemy: entity2 }
    };
    env = {
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
});
