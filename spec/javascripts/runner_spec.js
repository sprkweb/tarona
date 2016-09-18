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
    expect(runner.display.generators.length).not.toEqual(0);
  });

  it('creates a new connection', function() {
    expect(runner.messenger instanceof Messenger).toBeTruthy();
  });

  it('waits for acts', function() {
    expect(runner.messenger.listeners('act_start').length).not.toEqual(0);
  });

  it('runs the generator when an act is started', function() {
    spyOn(runner.display, 'generate');
    runner.messenger.happen('act_start', { type: 'foo', subject: 'bar' });
    expect(runner.display.generate).toHaveBeenCalledWith('foo', 'bar');
  });
});
