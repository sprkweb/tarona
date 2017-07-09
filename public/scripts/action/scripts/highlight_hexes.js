/**
 * Script for Action.Generator which highlights some kinds of hexagons in some
 * cases.
 *
 * @see Action.Generator
 */
function HighlightHexes(env, _data, essence) {
  var Highlight = function(klass) {
    this.klass = klass;
    this.nowHighlighted = [];

    this.highlight = function(hexes) {
      var self = this;
      hexes.forEach(function(hex) {
        var hex_obj = essence.hexes[hex[0]][hex[1]];
        hex_obj.backgroundElem.classList.add(self.klass);
        self.nowHighlighted.push(hex_obj);
      });
    };

    this.clear = function() {
      if (this.nowHighlighted === []) return;
      var self = this;
      this.nowHighlighted.forEach(function(hex) {
        hex.backgroundElem.classList.remove(self.klass);
      });
     this.nowHighlighted = [];
    };

    this.change = function(hexes) {
      this.clear();
      this.highlight(hexes);
    };
  };

  // Focused entity highlight
  var focusedHighlight = new Highlight('focused');
  var focusedEntity = null;
  var highlightNewFocus = function(inf) {
    focusedHighlight.clear();
    focusedEntity = null;
    if (inf.now && inf.now.hexes) {
      focusedHighlight.highlight(inf.now.hexes());
      focusedEntity = inf.now;
    }
  };
  essence.on('focusChange', highlightNewFocus);
  var move_highlight = function(inf) {
   var entity = essence.entities[inf.entity_id];
   if ((focusedEntity == entity) && inf.to)
     focusedHighlight.change(entity.hexes(inf.to));
  };
  env.io.on('move', move_highlight);

  env.display.on('before_act', function() {
    essence.remove_listener('focusChange', highlightNewFocus);
    env.io.remove_listener('move', move_highlight);
  });
}
