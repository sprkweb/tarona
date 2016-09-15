describe('Display', function() {
  var generator, generator_name, display, selector, data;
  beforeEach(function() {
    generator = jasmine.createSpy('generator');
    generator_name = 'foo';
    selector = 'body';
    display = new Display();
    display.addGenerator(generator_name, generator);
    data = { area_selector: selector };
  });

  it('keeps records of generators and invokes them', function() {
    display.generate(generator_name, data);
    expect(generator).toHaveBeenCalled();
  });
  
  it('clears created DOM before next act', function() {
    display.generate(generator_name, data);
    document.querySelector(selector).appendChild('div');
    expect(document.querySelector(selector)).not.toBeNull();
    display.generate(generator_name, data);
    expect(document.querySelector(selector)).toBeNull();
  });
  
  it('passes area object and given data as arguments to generator', function() {
    display.generate(generator_name, data);
    var area = document.querySelector(selector);
    expect(generator).toHaveBeenCalledWith(area, data);
  });
});