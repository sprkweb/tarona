describe('Form', function() {
  describe('Generator', function() {
    var realWaitForInput;
    beforeAll(function() {
      realWaitForInput = Form.WaitForInput;
      Form.WaitForInput = jasmine.createSpy();
    });
    afterAll(function() {
      Form.WaitForInput = realWaitForInput;
    });

    var area, selector, subject, env, data;
    beforeEach(function() {
      Form.WaitForInput = jasmine.createSpy();
      selector = '#test_area';
      area = document.querySelector(selector);
      subject = 'foo';
      env = { area: area, io: { happen: jasmine.createSpy('io#happen') } };
      data = { subject: subject };
      Form.Generator(env, data);
    });
    afterEach(function() {
      area.innerHTML = '';
    });

    it('creates container for the form', function() {
      expect(area.querySelector('div#form')).not.toBeNull();
    });

    it('writes form', function() {
      expect(area.querySelector('div#form').innerHTML).toEqual(subject);
    });

    it('says server when player filled the form', function() {
      var args = Form.WaitForInput.calls.argsFor(0);
      expect(args[0]).toBe(area.querySelector('div#form'));
      expect(args[1]).toBe(Form.GetData);
      args[2]('bar');
      expect(env.io.happen).toHaveBeenCalledWith('form_filled', 'bar');
    });
  });

  describe('WaitForInput', function() {
    var getData, callback, elem;
    beforeEach(function() {
      getData = jasmine.createSpy();
      callback = jasmine.createSpy();
      elem = document.createElement('div');
      elem.innerHTML = '<input name="foo" value="baz">' +
        '<input name="foo" type="button">' +
        '<button name="bar"></button>';
    });

    it('calls callback with form data when button is pressed', function() {
      elem.innerHTML = '<input name="foo" value="baz">' +
        '<input type="button" />';
      getData = function(arg) {
        expect(arg).toEqual(elem);
        return { foo: 'bar' };
      };
      Form.WaitForInput(elem, getData, callback);
      expect(callback).not.toHaveBeenCalled();
      RunFakeUserAction(elem.querySelector('input[type="button"]'), 'click');
      expect(callback).toHaveBeenCalledWith({ foo: 'bar' });
    });

    it('adds name of the clicked button to the form data', function() {
      getData = function(arg) { return { foo: 'bar' } };
      Form.WaitForInput(elem, getData, callback);
      RunFakeUserAction(elem.querySelector('input[type="button"]'), 'click');
      expect(callback).toHaveBeenCalledWith({ foo: 'bar', clicked: 'foo' });
    });

    it('also works with the button tag', function() {
      getData = function(arg) { return {} };
      Form.WaitForInput(elem, getData, callback);
      RunFakeUserAction(elem.querySelector('button'), 'click');
      expect(callback).toHaveBeenCalledWith({ clicked: 'bar' });
    });
  });

  describe('GetData', function() {
    it('can return data from inputs and textareas', function() {
      var elem = document.createElement('div');
      elem.innerHTML = '<input name="foo" value="baz">' +
        '<textarea name="bar">foobar</textarea>';
      expect(Form.GetData(elem)).toEqual({ foo: 'baz', bar: 'foobar' });
    });

    it('can not return data from elements without name', function() {
      var elem = document.createElement('div');
      elem.innerHTML = '<input value="baz"><textarea>foobar</textarea>';
      expect(Form.GetData(elem)).toEqual({});
    });
  });
});
