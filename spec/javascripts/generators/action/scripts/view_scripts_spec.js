describe('ViewScripts', function() {
  var env, data, essence, listener;
  beforeEach(function() {
    env = {
      io: Events.addEventsTo({}),
      display: Events.addEventsTo({})
    };
    data = jasmine.createSpy();
    essence = jasmine.createSpy();
    listener = jasmine.createSpy();
  });

  it('sends map_shown event after initialization', function() {
    env.io.on('map_shown', listener);
    ViewScripts(env, data, essence);
    expect(listener).toHaveBeenCalled();
  });

  it('runs script which is attached to the view_script event', function() {
    ViewScripts(env, data, essence);
    env.io.on('success', listener);
    env.io.happen('view_script', { script: 'env.io.happen("success")' });
    expect(listener).toHaveBeenCalled();
  });

  it('gives env, data and essence to the script', function() {
    ViewScripts(env, data, essence);
    env.io.happen('view_script', { script: 'data();essence(env)' });
    expect(data).toHaveBeenCalled();
    expect(essence).toHaveBeenCalledWith(env);
  });

  it('removes its listener after the act is ended', function() {
    ViewScripts(env, data, essence);
    spyOn(env.io, 'remove_listener');
    env.display.happen('before_act');
    expect(env.io.remove_listener)
      .toHaveBeenCalledWith('view_script', jasmine.any(Function));
  });
});
