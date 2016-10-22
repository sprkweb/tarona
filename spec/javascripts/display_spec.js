describe('Display', function() {
  var generator, generator_name, display, selector, env, data;
  beforeEach(function() {
    generator = jasmine.createSpy('generator');
    generator_name = 'foo';
    selector = '#test_area';
    env = { area_selector: selector };
    display = new Display(env);
    display.addGenerator(generator_name, generator);
    data = { valid: true };
  });

  it('keeps records of generators and invokes them', function() {
    display.generate(generator_name);
    expect(generator).toHaveBeenCalled();
  });

  it('clears created DOM before next act', function() {
    display.generate(generator_name);
    document.querySelector(selector).appendChild(document.createElement('div'));
    expect(document.querySelector(selector).innerHTML).not.toEqual('');
    display.generate(generator_name);
    expect(document.querySelector(selector).innerHTML).toEqual('');
  });

  it('passes some arguments to generator', function() {
    display.generate(generator_name, data);
    var area = document.querySelector(selector);
    var extended_env = _.extend(_.clone(env), { area: area });
    expect(generator).toHaveBeenCalledWith(extended_env, data);
  });

  it('can list you generators', function() {
    var generators = {};
    generators[generator_name] = generator;
    expect(display.generators).toEqual(generators);
  });

  it('triggers an event before an act is generated', function() {
    var before_generator = true;
    var triggered = false;
    display.on('before_act', function() {
      expect(before_generator).toBeTruthy();
      triggered = true;
    })
    display.addGenerator('bar', function() { before_generator = false });
    display.generate('bar', before_generator);
    expect(triggered).toBeTruthy();
  });
});
