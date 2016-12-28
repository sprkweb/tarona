describe('Messenger', function() {
  WebSocket = jasmine.createSpy('WebSocket');

  it('uses standard WebSocket object', function() {
    var messenger = new Messenger('ws://foo');
    var socket = messenger.socket;
    expect(WebSocket).toHaveBeenCalledWith('ws://foo');
  });

  var messenger;
  beforeEach(function() {
    messenger = new Messenger('ws://foo');
    messenger.socket = {
      send: function() {},
      onmessage: messenger.socket.onmessage,
      onopen: messenger.socket.onopen
    };
    spyOn(messenger.socket, 'send');
  });

  it('is event-driven', function() {
    Object.getOwnPropertyNames(Events).forEach(function(key) {
      if (key === 'addEventsTo') return;
      expect(messenger[key]).toBeDefined();
    });
  });

  it('converts output events to JSON', function() {
    messenger.happen('event', 'arg');
    var output = messenger.socket.send.calls.argsFor(0);
    expect(JSON.parse(output)).toEqual(['event', 'arg']);
  });

  it('converts input JSON to events', function() {
    listener = jasmine.createSpy('listener');
    messenger.on('foo', listener);
    messenger.socket.onmessage({ data: JSON.stringify(['foo', 'bar']) });
    expect(listener).toHaveBeenCalledWith('bar');
  });

  it('triggers `open` event when connection is open', function() {
    listener = jasmine.createSpy('listener');
    messenger.on('open', listener);
    messenger.socket.onopen();
    expect(listener).toHaveBeenCalled();
    expect(messenger.socket.send).not.toHaveBeenCalled();
  });
});
