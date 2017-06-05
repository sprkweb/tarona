describe('PlayerInteract.Movement', function() {
  var env, io, subj, listener;
  beforeEach(function() {
    listener = jasmine.createSpy();
    io = Events.addEventsTo({});
    env = { io: io };
    subj = PlayerInteract.Movement;
  });

  it('sends request to server', function() {
    io.on('move_request', listener);
    var entity = { id: 'foo' };
    subj(env, null, entity, [3, 4]);
    expect(listener).toHaveBeenCalledWith({ entity_id: 'foo', to: [3, 4] });
  });
});
