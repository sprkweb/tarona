describe('TextGenerator', function() {

  var area, selector, text, data;
  beforeEach(function() {
    selector = '#test_area';
    area = document.querySelector(selector);
    text = 'foo';
    TextGenerator({ area: area }, { subject: text });
  });

  it('creates container for text', function() {
    expect(area.querySelector('div#text')).not.toBeNull();
  });

  it('writes text', function() {
    expect(area.querySelector('div#text').innerHTML).toEqual(text);
  });

  afterEach(function() {
    area.innerHTML = '';
  });
});
