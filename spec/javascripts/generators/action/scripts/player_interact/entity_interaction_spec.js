describe('PlayerInteract.EntityInteraction', function() {
  var subj, env, io, area, listener, message, initiator, target, interactions,
    data;

  var realPopUp;
  beforeAll(function() {
    realPopUp = InteractivePopUp;
  });
  afterAll(function() {
    InteractivePopUp = realPopUp;
  });

  beforeEach(function() {
    InteractivePopUp = function() {
      var spy = InteractivePopUp.constructor;
      spy.apply(spy, arguments);
      return message;
    };
    InteractivePopUp.constructor = jasmine.createSpy();
    listener = jasmine.createSpy();
    io = Events.addEventsTo({});
    area = {};
    env = { io: io, area: area };
    subj = PlayerInteract.EntityInteraction;
    message = Events.addEventsTo({
      show: jasmine.createSpy('message#show')
    });
    interactions = {
      abc: { distance: 3, name: 'Qwe' },
      cba: { distance: 5, name: 'Ewq' }
    };
    initiator = { id: 'foo', coordinates: [2, 3], options:
      { interactions: interactions } };
    target = { id: 'bar', coordinates: [3, 3] };
    data = { subject: { i18n: { Qwe: 'Foo' } } };
  });

  it('shows popup for player to choose interaction', function() {
    subj(env, data, initiator, target);
    expect(InteractivePopUp.constructor).toHaveBeenCalledWith(
      area, jasmine.any(String), { stick_to: 'bottom-right', closable: true });
  });

  it('shows a form in the popup', function() {
    subj(env, data, initiator, target);
    var content = document.createElement('div');
    content.innerHTML = InteractivePopUp.constructor.calls.argsFor(0)[1];
    var buttons = content.querySelectorAll('form button');
    expect(buttons.length).toEqual(2);
    expect(buttons[0].name).toEqual('abc');
    var translated_name = data.subject.i18n[interactions.abc.name];
    expect(buttons[0].innerHTML).toEqual(translated_name);
    expect(buttons[1].name).toEqual('cba');
    expect(buttons[1].innerHTML).toEqual(interactions.cba.name);
  });

  it('sends request to server when interaction is chosen', function() {
    subj(env, data, initiator, target);
    io.on('interaction_request', listener);
    message.happen('close', { clicked: 'cba' });
    expect(listener).toHaveBeenCalledWith(
      { from_entity: 'foo', target: 'bar', interaction_id: 'cba' });
  });

  it('does nothing when interaction is not chosen', function() {
    subj(env, data, initiator, target);
    io.on('interaction_request', listener);
    message.happen('close');
    expect(listener).not.toHaveBeenCalled();
  });

  it('does not show interactions with too short maximal distance', function() {
    target = { id: 'bar', coordinates: [5, 5] };
    subj(env, data, initiator, target);
    var content = document.createElement('div');
    content.innerHTML = InteractivePopUp.constructor.calls.argsFor(0)[1];
    var buttons = content.querySelectorAll('form button');
    expect(buttons.length).toEqual(1);
    expect(buttons[0].name).toEqual('cba');
  });

  it('does not show popup when no interactions is applicable', function() {
    target = { id: 'bar', coordinates: [7, 7] };
    subj(env, data, initiator, target);
    expect(InteractivePopUp.constructor).not.toHaveBeenCalled();
  });
});
