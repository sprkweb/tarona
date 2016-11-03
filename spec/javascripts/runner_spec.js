describe('JS Engine runner', function() {
  var runner;
  beforeAll(function() {
    WebSocket = jasmine.createSpy('WebSocket');
    runner = new Runner();
    runner.messenger.socket = { send: function() {} }
  });

  it('creates a new display', function() {
    expect(runner.display instanceof Display).toBeTruthy();
  });

  it('registers some generators in the display', function() {
    [ ['action', ActionGenerator],
      ['text', TextGenerator]
    ].forEach(function(type) {
      expect(runner.display.generators[type[0]]).toBe(type[1]);
    });
  });

  it('creates a new connection', function() {
    expect(runner.messenger instanceof Messenger).toBeTruthy();
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
});
