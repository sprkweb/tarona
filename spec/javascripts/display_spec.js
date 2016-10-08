describe('Display', function() {
  var generator, generator_name, display, selector, data;
  beforeEach(function() {
    generator = jasmine.createSpy('generator');
    generator_name = 'foo';
    selector = '#test_area';
    display = new Display(selector);
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

  it('passes area object and given data as arguments to generator', function() {
    display.generate(generator_name, data);
    var area = document.querySelector(selector);
    expect(generator).toHaveBeenCalledWith(area, data);
  });

  it('can list you generators', function() {
    var generators = {};
    generators[generator_name] = generator;
    expect(display.generators).toEqual(generators);
  });
});
