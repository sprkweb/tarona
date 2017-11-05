/**
 * Script for Action.Generator which changes visible positions of entities
 * (including removal) when it is requested.
 *
 * @see Action.Generator
 */
function MoveEntity(env, _data, essence) {
  var self = this;
  this._init = function() {
    env.io.on('move', self._moveEntity);
    env.io.on('remove', self._removeEntity);
    env.display.on_first('before_act', function() {
      env.io.remove_listener('move', self._moveEntity);
      env.io.remove_listener('remove', self._removeEntity);
    });
  };

  this._moveEntity = function(inf) {
    // The code below needs some defence.
    var entity = essence.entities[inf.entity_id];
    if (!(entity && inf.to)) return;
    var prev_coords = entity.coordinates;
    essence.entities_grid.remove(prev_coords, entity);
    essence.entities_grid.add(inf.to, entity);
    entity.move(inf.to, true);
  };

  this._removeEntity = function(inf) {
    var entity = essence.entities[inf.entity_id];
    if (!entity) return;
    essence.entities_grid.remove(entity.coordinates, entity);
    entity.remove();
  };

  this._init();
}
