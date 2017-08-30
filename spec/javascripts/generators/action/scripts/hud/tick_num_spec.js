describe('HUD.TickNum', function() {
  var env, data, container;
  beforeEach(function() {
    env = {
      io: Events.addEventsTo({}),
      display: Events.addEventsTo({})
    };
    data = {
      subject: {
        i18n: { 'hud/tick_num': 'foo' },
        tick: 12
      }
    };
    container = HUD.TickNum(env, data);
  });

  it('creates container with one line', function() {
    expect(container.tagName).toEqual('DIV');
    expect(container.className).toEqual('info_list');
    expect(container.childNodes.length).toEqual(1);
    expect(container.childNodes[0].tagName).toEqual('P');
    expect(container.childNodes[0].childNodes.length).toEqual(2);
  });

  it('has translated label', function() {
    var label = container.childNodes[0].childNodes[0];
    expect(label.tagName).toEqual('SPAN');
    expect(label.innerHTML).toEqual('foo: ');
  });

  it('shows tick number', function() {
    var num = container.childNodes[0].childNodes[1];
    expect(num.tagName).toEqual('SPAN');
    expect(num.innerHTML).toEqual('12');
  });

  it('updates tick number after new tick', function() {
    env.io.happen('tick_start', { num: 17 });
    var num = container.childNodes[0].childNodes[1];
    expect(num.innerHTML).toEqual('17');
  });

  it('does not update tick number after act is ended', function() {
    env.display.happen('before_act');
    env.io.happen('tick_start', { num: 17 });
    var num = container.childNodes[0].childNodes[1];
    expect(num.innerHTML).toEqual('12');
  });
});
