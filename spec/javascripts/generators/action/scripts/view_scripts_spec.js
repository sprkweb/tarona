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

  it('shows visual effects when it is requested', function() {
    ViewScripts(env, data, essence);
    ViewScripts.EFFECTS.foobar = jasmine.createSpy('effect');
    env.io.happen('show_visual_effect', { name: 'foobar', params: 'baz' });
    expect(ViewScripts.EFFECTS.foobar)
      .toHaveBeenCalledWith(env, data, essence, 'baz');
    delete ViewScripts.EFFECTS.foobar;
  });

  it('removes its listeners after the act is ended', function() {
    ViewScripts(env, data, essence);
    spyOn(env.io, 'remove_listener');
    env.display.happen('before_act');
    expect(env.io.remove_listener)
      .toHaveBeenCalledWith('view_script', jasmine.any(Function));
    expect(env.io.remove_listener)
      .toHaveBeenCalledWith('show_visual_effect', jasmine.any(Function));
  });
});
