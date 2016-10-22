describe('TextGenerator', function() {

  var area, selector, text, data, io, click, keyup;
  var createFakeEvents = function() {
    try {
      click = new MouseEvent('click');
      keyup = new KeyboardEvent('keyup');
    } catch(_) {
      click = document.createEvent('MouseEvent');
      click.initEvent('click', true, false);
      keyup = document.createEvent('KeyboardEvent');
      keyup.initEvent('keyup', true, false);
    }
  };
  beforeEach(function() {
    createFakeEvents();
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
    area.dispatchEvent(click);
    expect(io.happen).toHaveBeenCalledWith('read');
  });

  it('says server to change act after player pushed a button', function() {
    document.dispatchEvent(keyup);
    expect(io.happen).toHaveBeenCalledWith('read');
  });

  it('does not says server to change act if player done nothing', function() {
    expect(io.happen).not.toHaveBeenCalledWith('read');
  });

  it('says server to change act only once', function() {
    document.dispatchEvent(click);
    document.dispatchEvent(click);
    document.dispatchEvent(keyup);
    expect(io.happen.calls.count()).toEqual(1);
  });

  afterEach(function() {
    area.innerHTML = '';
  });
});
