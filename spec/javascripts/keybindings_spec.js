describe('Keybindings', function() {
  // TODO: Make it available for all the tests and remove other similar places
  /**
   * Create fake event and run it.
   * @param target {Element} - element which will receive the event
   * @param event {String} - name of the event, e. g. click
   * @param additions {?object} - properties of the event, e.g. clientX
   * @return {CustomEvent} the event
   */
  var runFakeUserAction = function(target, event_name, additions) {
    var ev = document.createEvent('CustomEvent');
    ev.initEvent(event_name, true, false, null);
    if (additions) _.extend(ev, additions);
    target.dispatchEvent(ev);
    return ev;
  };
  var subj, display, target, listener;
  beforeEach(function() {
    display = jasmine.createSpy('display');
    target = document.createElement('div');
    listener = jasmine.createSpy('listener');
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
    var ev = runFakeUserAction(target, 'keypress', { code: 'KeyW' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to a special key', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'keydown', { code: 'Pause' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to a key with a digit', function() {
    expect(subj.bind(target, 'barbaz:up', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'keyup', { code: 'Digit1' });
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keydown event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:down', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'mousedown');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keypress event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:press', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'click');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind the keyup event to the left mouse button', function() {
    expect(subj.bind(target, 'foo:up', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'mouseup');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('can bind an event to the right mouse button', function() {
    expect(subj.bind(target, 'bar:press', listener)).toBeTruthy();
    var ev = runFakeUserAction(target, 'contextmenu');
    expect(listener).toHaveBeenCalledWith(ev);
  });

  it('returns false if the given key function is not valid', function() {
    expect(subj.bind(target, 'big_red_button:press', listener)).toBeFalsy();
    runFakeUserAction(target, 'keypress');
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if the given key action is not valid', function() {
    expect(subj.bind(target, 'foobar:dance', listener)).toBeFalsy();
    runFakeUserAction(target, 'keydance');
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if you use mouse2 with "up" action', function() {
    expect(subj.bind(target, 'bar:up', listener)).toBeFalsy();
    runFakeUserAction(target, 'keyup', { code: 'Mouse2' });
    expect(listener).not.toHaveBeenCalled();
  });

  it('returns false if you use mouse2 with "down" action', function() {
    expect(subj.bind(target, 'bar:down', listener)).toBeFalsy();
    runFakeUserAction(target, 'mousedown');
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not trigger listener if another key is pressed', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    runFakeUserAction(target, 'keydown', { code: 'Space' });
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not trigger listener if another action is done', function() {
    expect(subj.bind(target, 'foobar:down', listener)).toBeTruthy();
    runFakeUserAction(target, 'keyup', { code: 'Pause' });
    expect(listener).not.toHaveBeenCalled();
  });
});
