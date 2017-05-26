describe('InteractivePopUp', function() {
  var selector, area, listener, options;
  beforeEach(function() {
    selector = '#test_area';
    area = document.querySelector(selector);
    area.innerHTML = '';
    listener = jasmine.createSpy('listener');
    options = { stick_to: 'top-left', closable: true };
  });

  it('can create popup with a form', function() {
    var content = '<form><input type="button" value="OK"></form>';
    (new InteractivePopUp(area, content, options)).show();
    var elem = area.querySelector(
      '#popup_container > .corners #popup_top-left > .message');
    expect(elem).not.toBeNull();
    var content_elem = elem.childNodes[1];
    expect(content_elem.querySelector(
      'form > input[type="button"][value="OK"]')).not.toBeNull();
    var close_elem = elem.childNodes[0];
    expect(close_elem.className).toEqual('close');
  });

  it('closes popup when button is pressed', function() {
    var content = '<form><input type="button" value="OK"></form>';
    var subj = new InteractivePopUp(area, content, options);
    subj.show();
    subj.on('close', listener);
    var button = subj.elem.querySelector('input[type="button"]');
    RunFakeUserAction(button, 'click');
    expect(listener).toHaveBeenCalled();
  });

  describe('`close` event', function() {
    it('contents values of form fields', function() {
      var content = '<form><input type="text" value="Andrew" name="bar">' +
        '<textarea name="foo">Maria</textarea>' +
        '<input type="hidden" name="name" value="Ivan">' +
        '<input type="button" name="button" value="OK"></form>';
      var subj = new InteractivePopUp(area, content, options);
      subj.show();
      subj.on('close', listener);
      var button = subj.elem.querySelector('input[type="button"]');
      RunFakeUserAction(button, 'click');
      expect(listener.calls.first().args[0]).toEqual(jasmine.objectContaining({
        bar: 'Andrew',
        foo: 'Maria',
        name: 'Ivan',
        button: 'OK'
      }));
    });

    it('does not include form fields without value or name', function() {
      var content = '<form><input type="hidden" name="name">' +
        '<input type="button" value="OK"></form>';
      var subj = new InteractivePopUp(area, content, options);
      subj.show();
      subj.on('close', listener);
      var button = subj.elem.querySelector('input[type="button"]');
      RunFakeUserAction(button, 'click');
      expect(listener.calls.first().args[0]).toEqual({});
    });

    it('contents name of the clicked button with `clicked` key', function() {
      var content = '<form><input type="hidden" name="name" value="Ivan">' +
        '<input type="button" name="leonid" value="OK"></form>';
      var subj = new InteractivePopUp(area, content, options);
      subj.show();
      subj.on('close', listener);
      var button = subj.elem.querySelector('input[type="button"]');
      RunFakeUserAction(button, 'click');
      expect(listener.calls.first().args[0].clicked).toEqual('leonid');
    });

    it('contents nothing when the #close method is called', function() {
      var content = '<form><input type="text" value="Andrew" name="bar">' +
        '<input type="button" name="foo" value="OK"></form>';
      var subj = new InteractivePopUp(area, content, options);
      subj.show();
      subj.on('close', listener);
      subj.close();
      expect(listener).toHaveBeenCalledWith(undefined);
    });

    it('contents nothing when the close button is pressed', function() {
      var content = '<form><input type="password" value="Andrew" name="bar">' +
        '<button name="foo" value="OK">OK</form>';
      var subj = new InteractivePopUp(area, content, options);
      subj.show();
      subj.on('close', listener);
      RunFakeUserAction(subj.closeButton, 'click');
      expect(listener).toHaveBeenCalledWith(undefined);
    });
  });
});
