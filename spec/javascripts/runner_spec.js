describe('JS Engine runner', function() {
  var runner;
  beforeAll(function() {
    document.cookie = 'session_id = 0; expires=Mon, 2 May 2011 07:42:03 GMT';
    WebSocket = jasmine.createSpy('WebSocket');
    runner = new Runner();
    runner.messenger.socket = { send: function() {} }
  });

  it('creates a new display', function() {
    expect(runner.display instanceof Display).toBeTruthy();
  });

  it('registers some generators in the display', function() {
    [ ['action', Action.Generator],
      ['text', TextGenerator]
    ].forEach(function(type) {
      expect(runner.display.generators[type[0]]).toBe(type[1]);
    });
  });

  it('creates a new connection', function() {
    expect(runner.messenger instanceof Messenger).toBeTruthy();
  });

  it('notifies messenger when it is ready', function() {
    listener = jasmine.createSpy('listener');
    runner.messenger.on('display_ready', listener)
    runner.messenger.happen('open');
    expect(listener).toHaveBeenCalled();
  });

  it('waits for acts', function() {
    expect(runner.messenger.listeners('act_start').length).not.toEqual(0);
  });

  it('runs the generator when an act is started', function() {
    spyOn(runner.display, 'generate');
    var act = { type: 'foo', subject: 'bar' };
    runner.messenger.happen('act_start', act);
    expect(runner.display.generate).toHaveBeenCalledWith(act.type, act);
  });

  it('saves session id to cookie', function() {
    runner.messenger.happen('new_session', { hash: '12345' });
    expect(document.cookie.match(/session_id=12345/g)).toBeTruthy();
  });

  it('send session id when it is ready', function() {
    runner.messenger.happen('new_session', { hash: '-123foo' });
    listener = jasmine.createSpy('listener');
    runner.messenger.on('display_ready', listener)
    runner.messenger.happen('open');
    expect(listener).toHaveBeenCalledWith({ session_id: '-123foo' });
  });
});
