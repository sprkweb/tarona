describe('PopUp', function() {
  var selector, area;
  beforeEach(function() {
    selector = '#test_area';
    area = document.querySelector(selector);
  });
  afterEach(function() {
    area.innerHTML = '';
  });

  it('can create simple pop-up window', function() {
    var options = { closable: false, stick_to: 'top-left' };
    var subj = new PopUp(area, 'foo', options);
    subj.show();
    var elem = area.querySelector(
      '#popup_container > .corners #popup_top-left > .message');
    expect(elem).not.toBeNull();
    var content = elem.childNodes[0];
    expect(content.className).toEqual('message_content');
    expect(content.innerHTML).toEqual('foo');
  });

  it('does not create new containers for new popups', function() {
    var options = { closable: false, stick_to: 'bottom-right' };
    (new PopUp(area, 'foo', options)).show();
    (new PopUp(area, 'bar', options)).show();
    var container = area.querySelectorAll('#popup_container > .corners');
    expect(container.length).toEqual(1);
    var elems = container[0].querySelectorAll('#popup_bottom-right > .message');
    expect(elems.length).toEqual(2);
    expect(elems[0].childNodes[0].innerHTML).toEqual('foo');
    expect(elems[1].childNodes[0].innerHTML).toEqual('bar');
  });

  it('can create a close button', function() {
    var options = { closable: true, stick_to: 'top-right' };
    var subj = new PopUp(area, '<br>', options);
    subj.show();
    var elem = area.querySelector(
      '#popup_container > .corners #popup_top-right > .message');
    expect(elem.childNodes[0]).toBe(subj.closeButton);
    expect(elem.childNodes[1].className).toEqual('message_content');
    expect(elem.childNodes[1].innerHTML).toEqual('<br>');
  });

  it('uses span#close to show close button', function() {
    var options = { closable: true, stick_to: 'top-right' };
    var subj = new PopUp(area, 'baz', options);
    subj.show();
    expect(subj.closeButton.className).toEqual('close');
    expect(subj.closeButton.tagName).toEqual('SPAN');
    expect(subj.closeButton.innerHTML).toEqual('');
  });

  it('closes window when its close button is pressed', function() {
    var listener = jasmine.createSpy('listener');
    var options = { closable: true, stick_to: 'bottom-left' };
    var subj = new PopUp(area, 'foo', options);
    subj.show();
    subj.on('close', listener);
    RunFakeUserAction(subj.closeButton, 'click');
    expect(listener).toHaveBeenCalled();
    var button = area.querySelector(
      '#popup_container > .corners #popup_bottom-left > .message');
    expect(button).toBeNull();
  });

  it('closes window when the #close method is called', function() {
    var listener = jasmine.createSpy('listener');
    var options = { closable: true, stick_to: 'bottom-left' };
    var subj = new PopUp(area, 'foo', options);
    subj.show();
    subj.on('close', listener);
    subj.close();
    expect(listener).toHaveBeenCalled();
    var button = area.querySelector(
      '#popup_container > .corners #popup_bottom-left > .message');
    expect(button).toBeNull();
  });

  it('does nothing when the #show method is not called', function() {
    var options = { closable: false, stick_to: 'top-left' };
    new PopUp(area, 'foo', options);
    expect(document.getElementById('#popup_container')).toBeNull();
  });

  it('has #elem attribute', function() {
    var options = { closable: false, stick_to: 'top-left' };
    var subj = new PopUp(area, 'foo', options);
    subj.show();
    var elem = area.querySelector(
      '#popup_container > .corners #popup_top-left > .message');
    expect(elem).toBe(subj.elem);
  });
});
