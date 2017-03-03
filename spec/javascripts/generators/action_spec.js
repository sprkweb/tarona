describe('Action.Generator', function() {
  var run, area, selector, subject, io, env, data, script;
  beforeEach(function() {
    selector = '#test_area';
    io = {
      on: jasmine.createSpy('io#on'),
      happen: jasmine.createSpy('io#happen')
    };
    area = document.querySelector(selector);
    var man = {
      id: 'man',
      svg_id: 'mysymbol',
      hexes: { odd_row: [[0, 0], [1, 1]], even_row: [[0, 0], [0, 1]] }
    };
    var woman = {
      id: 'woman',
      svg_id: 'mysymbol2',
      hexes: { odd_row: [[0, 0], [0, -1]], even_row: [[0, 0], [-1, -1]] }
    };
    subject = {
      hex_size: 10,
      landscape: [
        [{ g: { svg_id: 'mypattern' }, e: [man] }, { e: [man] }],
        [{}, {}],
        [{ e: [woman] }, { e: [woman] }]
      ],
      entities_index: { man: [0, 0], woman: [2, 1] },
      dependencies: '<g id="check_deps"></g>'
    };
    script = jasmine.createSpy('script');
    run = function() {
      area.innerHTML = '';
      env = { area: area, io: io, scripts: [script] };
      data = { subject: subject };
      Action.Generator(env, data);
    };
    run();
  });

  describe('markup', function() {
    it('includes wrapped svg', function() {
      var wrapper = document.getElementById('field');
      expect(wrapper).not.toBeNull();
      var svg = wrapper.getElementsByTagName('svg');
      expect(svg.length).toBe(1);
    });

    it('includes svg defs', function() {
      var defs = document.querySelector('#field > svg > defs');
      expect(defs).not.toBeNull();
    })

    it('includes svg defs dependencies', function() {
      var defs = document.querySelector('#field > svg > defs');
      expect(defs.innerHTML.indexOf(subject.dependencies)).not.toBe(-1);
    })

    it('includes svg hex definition', function() {
      var hex = document.querySelector('#field > svg > defs > path#hex');
      expect(hex).not.toBeNull();
      expect(hex.getAttribute('d')).toEqual('M 8.6602540378 5 L 0 10 L -8.6602540378 5 L -8.6602540378 -5 L 0 -10 L 8.6602540378 -5 Z');
    });

    it('includes clip path of hex', function() {
      var defs = document.querySelector('#field > svg > defs');
      var clip = defs.getElementsByTagName('clipPath')[0];
      expect(clip).not.toBeNull();
      expect(clip.getAttribute('id')).toEqual('hexclip');
      expect(clip.getAttribute('clipPathUnits')).toEqual('objectBoundingBox');
      expect(clip.childNodes.length).toEqual(1);
      var path = clip.firstChild;
      expect(path.nodeName).toEqual('path');
      expect(path.attributes.length).toEqual(1);
      expect(path.attributes.getNamedItem('d').value)
        .toEqual('M 1 0.75 L 0.5 1 L 0 0.75 L 0 0.25 L 0.5 0 L 1 0.25 Z');
    });

    it('includes container for hexes', function() {
      var hexes = document.querySelector('#field > svg > g#hexes');
      expect(hexes).not.toBeNull();
    });

    it('includes container for entities', function() {
      var entities = document.querySelector('#field > svg > g#entities');
      expect(entities).not.toBeNull();
    });

    var shouldBeHexes = function() {
      var hexes = document.querySelectorAll('#field > svg > g#hexes > use');
      var args = arguments;
      expect(hexes.length).toBe(args.length);
      _.each(hexes, function(hex) {
        var x = parseFloat(hex.getAttribute('x'));
        var y = parseFloat(hex.getAttribute('y'));
        var gotIt = _.some(args, function(a) {
          return (a[0] == x) && (a[1] == y);
        });
        expect(gotIt).toBeTruthy();
        expect(hex.getAttribute('href')).toEqual('#hex');
      });
    };

    it('uses prototype of hex to create hexagonal grid', function() {
      shouldBeHexes([8.660254037844386, 10], [17.32050807568877, 25],
        [25.980762113533157, 10], [34.64101615137754, 25],
        [43.301270189221924, 10], [51.96152422706631, 25]);
    });

    var checkScale = function(width, height) {
      var svg = document.querySelector('#field > svg');
      expect(svg.getAttribute('width')).toBeCloseTo(width, 2);
      expect(svg.getAttribute('height')).toBeCloseTo(height, 2);
      var border = svg.getAttribute('viewBox').split(' ');
      expect(border[0]).toEqual('0');
      expect(border[1]).toEqual('0');
      expect(border[2]).toEqual(svg.getAttribute('width'));
      expect(border[3]).toEqual(svg.getAttribute('height'));
    };

    it('scales svg', function() {
      checkScale(60.62, 35);
      subject = {
        hex_size: 15,
        landscape: [[{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}]]
      };
      run();
      checkScale(116.91, 75);
    });

    it('uses ground patterns', function() {
      var filled_hex = document.querySelectorAll('#field > svg > g#hexes > use');
      expect(_.some(filled_hex, function(hex) {
        return (
          (hex.getAttribute('fill') === 'url(#mypattern)') &&
          (hex.getAttribute('stroke') === 'url(#mypattern)'))
      })).toBeTruthy();
    });

    it('sets data-type attribute for hexes', function() {
      var hexes = document.querySelectorAll('#field > svg > g#hexes > use');
      expect(_.every(hexes, function(hex) {
        return (hex.getAttribute('data-type') === 'hex');
      })).toBeTruthy();
    });

    it('shows entities', function() {
      var entity = document.querySelector('#field > svg > g#entities > use');
      expect(entity.getAttribute('href')).toEqual('#mysymbol');
    });

    it('shows entities at their places', function() {
      var entity = document.querySelector('#field > svg > g#entities > use');
      expect(entity.getAttribute('x')).toEqual('8.660254037844386');
      expect(entity.getAttribute('y')).toEqual('10');
    });

    it('sets data-type attribute for entities', function() {
      var entity = document.querySelector('#field > svg > g#entities > use');
      expect(entity.getAttribute('data-type')).toEqual('entity');
    });

    it('sets entity\'s id as an attribute', function() {
      var entity = document.querySelector('#field > svg > g#entities > use');
      expect(entity.getAttribute('data-entity_id')).toEqual('man');
    });

    it('shows entities accordingly to entities_index', function() {
      var entity2 =
        document.querySelectorAll('#field > svg > g#entities > use')[1];
      expect(entity2.getAttribute('x')).toEqual('51.96152422706631');
      expect(entity2.getAttribute('y')).toEqual('25');
    });

    it('shows each entity once though they has multiple places', function() {
      var entities =
        document.querySelectorAll('#field > svg > g#entities > use');
      expect(entities.length).toEqual(2);
    });
  });

  describe('scripts', function() {
    it('are called', function() {
      expect(script.calls.count()).toEqual(1);
    });

    it('receive arguments of generator as first two arguments', function() {
      expect(_.first(script.calls.argsFor(0), 2)).toEqual([env, data]);
    });
  });

  describe('essence', function() {
    var essence;
    beforeEach(function() {
      essence = script.calls.argsFor(0)[2];
    });

    it('is passed to scripts as a third argument', function() {
      expect(typeof essence).toEqual('object')
    });

    it('includes field element', function() {
      expect(essence.field).toBe(
        document.getElementById('field').getElementsByTagName('svg')[0]);
    });

    it('includes numbers of columns and rows', function() {
      expect(essence.cols).toEqual(3);
    });

    it('includes number of rows', function() {
      expect(essence.rows).toEqual(2);
    });

    it('includes hexagon geomeric definition', function() {
      expect(essence.hex instanceof Action.Hex).toBeTruthy();
      expect(essence.hex.size).toEqual(10);
    });

    it('includes size of the field', function() {
      expect(essence.width).toEqual(
        Action.HexGrid.width(essence.cols, essence.hex));
      expect(essence.height).toEqual(
        Action.HexGrid.height(essence.rows, essence.hex));
    });

    it('includes container element for hexagons', function() {
      expect(essence.hexesElem).toEqual(
        document.querySelector('#field > svg > g#hexes'));
    });

    it('includes container element for entities', function() {
      expect(essence.entitiesElem).toEqual(
        document.querySelector('#field > svg > g#entities'));
    });

    it('includes matrix with objects of hexagons', function() {
      essence.hexes.forEach(function(col, colNum) {
        col.forEach(function(hex, rowNum) {
          expect(hex instanceof Action.SVGHex).toBeTruthy();
          expect(hex.options.backgroundParentElem).toBe(essence.hexesElem);
          expect(hex.options.templateId).toEqual('hex');
          expect(hex.place).toEqual(
            Action.HexGrid.coords2px([colNum, rowNum], essence.hex));
        });
      });
    });

    it('includes objects of entities', function() {
      var entity = essence.entities['man'];
      expect(entity instanceof Action.Entity).toBeTruthy();
      expect(entity.coordinates).toEqual([0, 0]);
      expect(entity.hex).toBe(essence.hex);
      expect(entity.elem.getAttribute('href')).toEqual('#mysymbol');
    });

    it('includes objects of all entities', function() {
      var entity = essence.entities['woman'];
      expect(entity instanceof Action.Entity).toBeTruthy();
      expect(entity.coordinates).toEqual([2, 1]);
      expect(entity.hex).toBe(essence.hex);
      expect(entity.elem.getAttribute('href')).toEqual('#mysymbol2');
    });

    it('includes grid of entities', function() {
      var man = essence.entities['man'];
      var woman = essence.entities['woman'];
      expect(essence.entities_grid instanceof Action.EntitiesGrid).toBeTruthy();
      expect(essence.entities_grid.grid).toEqual([
        [[man], [man]],
        undefined,
        [[woman], [woman]],
      ]);
    });

    describe('events', function() {
      var createFakeMousemove = function(offset) {
        var el = essence.field;
        var coords = el.getBoundingClientRect();
        RunFakeUserAction(el, 'mousemove', {
          pageX: coords.left + offset[0],
          pageY: coords.top + offset[1]
        });
      };

      beforeEach(function() {
        essence.on('hoverHex', function(ev) {
          expect(essence.hovered_hex).toEqual(ev.now);
        });
        essence.on('focusChange', function(ev) {
          expect(essence.focused).toEqual(ev.now);
        });
      });

      it('triggers event when a hexagon is hovered', function() {
        listener = jasmine.createSpy('listener');
        essence.on('hoverHex', listener);
        createFakeMousemove([17.5, 23.3]);
        expect(listener).toHaveBeenCalledWith({ was: null, now: [0, 1] });
      });

      it('passes last hovered hexagon as an option to hoveHex', function() {
        listener = jasmine.createSpy('listener');
        essence.on('hoverHex', listener);
        createFakeMousemove([17.2, 24.3]);
        createFakeMousemove([34.2, 24.3]);
        expect(listener).toHaveBeenCalledWith({ was: [0, 1], now: [1, 1] });
      });

      it('does not trigger hoverHex event if hex not changed', function() {
        listener = jasmine.createSpy('listener');
        createFakeMousemove([17.2, 24.3]);
        essence.on('hoverHex', listener);
        createFakeMousemove([17.3, 24.2]);
        expect(listener).not.toHaveBeenCalled();
      });

      it('does not trigger hoverHex event if hex not hovered', function() {
        listener = jasmine.createSpy('listener');
        essence.on('hoverHex', listener);
        createFakeMousemove([999, 993]);
        createFakeMousemove([999, 999]);
        expect(listener).not.toHaveBeenCalled();
      });

      it('triggers hoverHex event if hex have been hovered', function() {
        listener = jasmine.createSpy('listener');
        createFakeMousemove([17.2, 24.3]);
        essence.on('hoverHex', listener);
        createFakeMousemove([999, 999]);
        expect(listener).toHaveBeenCalledWith({ was: [0, 1], now: null });
      });

      var entity, entity2, not_entity;
      beforeEach(function() {
        entity = essence.entities['man'].elem;
        entity2 = essence.entities['woman'].elem;
        not_entity = essence.hexes[0][1].backgroundElem;
      });

      it('triggers focusChange event if entity is clicked', function() {
        listener = jasmine.createSpy('listener');
        essence.on('focusChange', listener);
        RunFakeUserAction(entity, 'click');
        expect(listener).toHaveBeenCalledWith({
          was: null,
          now: essence.entities['man']
        });
      });

      it('does not trigger focusChange if it is the same entity', function() {
        listener = jasmine.createSpy('listener');
        RunFakeUserAction(entity, 'click');
        essence.on('focusChange', listener);
        RunFakeUserAction(entity, 'click');
        expect(listener).not.toHaveBeenCalled();
      });

      it('passes last entity to focusChange event', function() {
        RunFakeUserAction(entity, 'click');
        listener = jasmine.createSpy('listener');
        essence.on('focusChange', listener);
        RunFakeUserAction(entity2, 'click');
        expect(listener).toHaveBeenCalledWith({
          was: essence.entities['man'],
          now: essence.entities['woman']
        });
      });

      it('clears focus if you clicked not entity', function() {
        RunFakeUserAction(entity, 'click');
        listener = jasmine.createSpy('listener');
        essence.on('focusChange', listener);
        RunFakeUserAction(not_entity, 'click');
        expect(listener).toHaveBeenCalledWith({
          was: essence.entities['man'],
          now: null
        });
      });

      it('clears focus if non-existent entity clicked', function() {
        essence.entities['woman'] = undefined;
        RunFakeUserAction(entity, 'click');
        listener = jasmine.createSpy('listener');
        essence.on('focusChange', listener);
        RunFakeUserAction(not_entity, 'click');
        expect(listener).toHaveBeenCalledWith({
          was: essence.entities['man'],
          now: null
        });
      });

      it('does not trigger focusChange if you focused no entity', function() {
        listener = jasmine.createSpy('listener');
        essence.on('focusChange', listener);
        createFakeMousemove(not_entity);
        expect(listener).not.toHaveBeenCalled();
      });

      it('blocks context menu', function() {
        preventDefault = jasmine.createSpy('preventDefault');
        RunFakeUserAction(essence.field, 'contextmenu', {
          preventDefault: preventDefault
        });
        expect(preventDefault).toHaveBeenCalled();
      });
    });
  });

  afterEach(function() {
    area.innerHTML = '';
  });
});
