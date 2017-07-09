/**
 * Script for Action.Generator which changes player's field of view when it is
 * requested.
 *
 * @see Action.Generator
 */
function FovOperator(env, _data, _essence) {
  var speed = document.body.clientHeight / 500;
  var fov = env.area.querySelector('#field');
  var directions = {
    up: function(start, dist) { fov.scrollTop = start[0] - dist },
    down: function(start, dist) { fov.scrollTop = start[0] + dist },
    left: function(start, dist) { fov.scrollLeft = start[1] - dist },
    right: function(start, dist) { fov.scrollLeft = start[1] + dist }
  };
  var is_pressed = { up: false, down: false, left: false, right: false };

  ['up', 'down', 'left', 'right'].forEach(function(direction) {
    env.keybindings.bind(document, direction + ':down', function(ev) {
      if (ev.repeat) return;
      is_pressed[direction] = true;
      var start = performance.now();
      var start_scroll = [fov.scrollTop, fov.scrollLeft];
      var animate = function(time) {
        var timePassed = time - start;
        var moveDist = timePassed * speed;
        directions[direction](start_scroll, moveDist);
        if (is_pressed[direction]) requestAnimationFrame(animate);
      };
      requestAnimationFrame(animate);
    });
    env.keybindings.bind(document, direction + ':up', function() {
      is_pressed[direction] = false;
    });
  });
}
