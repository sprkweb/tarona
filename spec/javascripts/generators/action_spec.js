describe('ActionGenerator', function() {
  var run, area, selector, subject, io;
  beforeEach(function() {
    selector = '#test_area';
    io = {
      on: jasmine.createSpy('io#on'),
      happen: jasmine.createSpy('io#happen')
    };
    area = document.querySelector(selector);
    subject = {
      hex_size: 10,
      landscape: [[{ g: { svg_id: 'mypattern' }, e: [{ svg_id: 'mysymbol' }] }, {}], [{}, {}], [{}, {}]],
      dependencies: '<g id="check_deps"></g>'
    };
    run = function() {
      area.innerHTML = '';
      ActionGenerator({ area: area, io: io }, { subject: subject });
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
      var path = clip.querySelector('use[href="#hex"][x="0"][y="0"]');
      expect(path).not.toBeNull();
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
      })).toBeTruthy()
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
  });

  afterEach(function() {
    area.innerHTML = '';
  });
});
