describe('TextGenerator', function() {

  var area, selector, text, data, io;
  beforeEach(function() {
    selector = '#test_area';
    io = {
      on: jasmine.createSpy('io#on'),
      happen: jasmine.createSpy('io#happen')
    };
    area = document.querySelector(selector);
    text = 'foo';
    TextGenerator({ area: area, io: io }, { subject: text });
  });

  it('creates container for text', function() {
    expect(area.querySelector('div#text')).not.toBeNull();
  });

  it('writes text', function() {
    expect(area.querySelector('div#text').innerHTML).toEqual(text);
  });

  it('says server to change act after player clicked', function() {
    RunFakeUserAction(area, 'click');
    expect(io.happen).toHaveBeenCalledWith('read');
  });

  it('says server to change act after player pushed a button', function() {
    RunFakeUserAction(document, 'keyup');
    expect(io.happen).toHaveBeenCalledWith('read');
  });

  it('does not says server to change act if player done nothing', function() {
    expect(io.happen).not.toHaveBeenCalledWith('read');
  });

  it('says server to change act only once', function() {
    RunFakeUserAction(area, 'click');
    RunFakeUserAction(area, 'click');
    RunFakeUserAction(document, 'keyup');
    expect(io.happen.calls.count()).toEqual(1);
  });

  afterEach(function() {
    area.innerHTML = '';
  });
});
