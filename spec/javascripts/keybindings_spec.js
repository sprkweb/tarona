describe('Keybindings', function() {
  var subj, display, target, listener, listener2;
  beforeEach(function() {
    display = Events.addEventsTo({});
    target = document.createElement('div');
    listener = jasmine.createSpy('listener');
    listener2 = jasmine.createSpy('listener2');
    subj = new Keybindings(display);
    subj.bindings = {
      foo: 'Mouse1',
      bar: 'Mouse2',
      baz: 'KeyW',
      foobar: 'Pause',
      barbaz: 'Digit1'
    };
  });

  it('can bind an event to a key with a letter', function() {
    expect(subj.bind(target, 'baz:press', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'keypress', { code: 'KeyW' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to a special key', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'keydown', { code: 'Pause' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to a key with a digit', function() {
    expect(subj.bind(target, 'barbaz:up', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'keyup', { code: 'Digit1' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keydown event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:down', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'mousedown');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keypress event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:press', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'click');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keyup event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:up', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'mouseup');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to the right mouse button', function() {
    expect(subj.bind(target, 'bar:press', listener)).toBeTruthy();
    var ev = RunFakeUserAction(target, 'contextmenu');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('returns false if the given key function is not valid', function() {
    expect(subj.bind(target, 'big_red_button:press', listener)).toBeFalsy();
    RunFakeUserAction(target, 'keypress');
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if the given key action is not valid', function() {
    expect(subj.bind(target, 'foobar:dance', listener)).toBeFalsy();
    RunFakeUserAction(target, 'keydance');
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if you use mouse2 with "up" action', function() {
    expect(subj.bind(target, 'bar:up', listener)).toBeFalsy();
    RunFakeUserAction(target, 'keyup', { code: 'Mouse2' });
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if you use mouse2 with "down" action', function() {
    expect(subj.bind(target, 'bar:down', listener)).toBeFalsy();
    RunFakeUserAction(target, 'mousedown');
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not trigger listener if another key is pressed', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    RunFakeUserAction(target, 'keydown', { code: 'Space' });
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not trigger listener if another action is done', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    RunFakeUserAction(target, 'keyup', { code: 'Pause' });
    expect(listener).not.toHaveBeenCalled();
  });

  it('removes listener after act is ended', function() {
    subj.bind(target, 'foo:down', listener);
    subj.bind(target, 'bar:press', listener2, true);
    display.happen('before_act');
    RunFakeUserAction(target, 'mousedown');
    RunFakeUserAction(target, 'contextmenu');
    expect(listener).not.toHaveBeenCalled();
    expect(listener2).not.toHaveBeenCalled();
  });

  it('does not remove binding when act is ended and for_act arg is false', function() {
    subj.bind(target, 'foo:down', listener);
    subj.bind(target, 'bar:press', listener2, false);
    display.happen('before_act');
    RunFakeUserAction(target, 'mousedown');
    RunFakeUserAction(target, 'contextmenu');
    expect(listener).not.toHaveBeenCalled();
    expect(listener2).toHaveBeenCalled();
  });
});
