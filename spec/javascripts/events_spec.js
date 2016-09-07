describe('Events', function() {
  var subject;
  var listener = function () {};
  var listener2 = function () {};
  beforeEach(function() {
    subject = Events.addEventsTo({});
  });

  it('can mix itself to objects', function() {
    Object.getOwnPropertyNames(Events).forEach(function(key) {
      expect(subject[key]).toBeDefined();
    });
  });

  describe('#on', function() {
    it('allow bind event listener', function () {
      subject.on('my_event', listener);
      expect(subject.listeners('my_event')).toEqual([listener]);
    });

    it('allow bind listeners to many events', function () {
      subject.on('1', listener);
      subject.on('2', listener2);
      expect(subject.listeners('1')).toEqual([listener]);
      expect(subject.listeners('2')).toEqual([listener2]);
    });

    it('allow bind many listeners to an event', function () {
      subject.on('my_event', listener);
      subject.on('my_event', listener2);
      expect(subject.listeners('my_event')).toEqual([listener, listener2]);
    });
  });

  describe('#remove_listener', function() {
    beforeEach(function() {
      subject.on('my_event', listener);
      subject.on('my_event', listener2);
      subject.on('another_event', listener);
    });

    it('detachs given listener from the given event', function() {
      subject.remove_listener('my_event', listener);
      expect(subject.listeners('my_event')).toEqual([listener2]);
      expect(subject.listeners('another_event')).toEqual([listener]);
    });

    it('detachs all the listeners from the givenevent when ' +
      'there is listener given', function () {
      subject.remove_listener('my_event');
      expect(subject.listeners('my_event')).toEqual([]);
      expect(subject.listeners('another_event')).toEqual([listener]);
    });
  });

  describe('#happen', function() {
    beforeEach(function() {
      listener = jasmine.createSpy('listener');
      listener2 = jasmine.createSpy('listener2');
      subject.on('my_event', listener);
      subject.on('my_event', listener2);
      subject.on('another_event', listener);
    });

    it('executes all the event listeners', function() {
      subject.happen('another_event');
      expect(listener2).toHaveBeenCalled();
      expect(listener).not.toHaveBeenCalled();
    });

    it('do nothing when there is no listeners', function() {
      subject.remove_listener('my_event');
      subject.happen('my_event');
      expect(listener).not.toHaveBeenCalled();
      expect(listener2).not.toHaveBeenCalled();
    });

    it('passes data as an argument to listeners', function() {
      var my_data = { valid: true };
      subject.happen('my_event', my_data);
      expect(listener).toHaveBeenCalledWith(my_data);
    });
  });
});