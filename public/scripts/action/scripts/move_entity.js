/**
 * Script for Action.Generator which changes visible positions of entities
 * (including removal) when it is requested.
 *
 * @see Action.Generator
 */
function MoveEntity(env, _data, essence) {
  var self = this;
  this._init = function() {
    env.io.on('add_entity', self._addEntity);
    env.io.on('move', self._moveEntity);
    env.io.on('remove', self._removeEntity);
    env.display.on_first('before_act', function() {
      env.io.remove_listener('add_entity', self._addEntity);
      env.io.remove_listener('move', self._moveEntity);
      env.io.remove_listener('remove', self._removeEntity);
    });
  };

  this._addEntity = function(inf) {
    Action.PlaceEntity.add(inf.entity_inf, inf.place, essence);
  };

  this._moveEntity = function(inf) {
    Action.PlaceEntity.move(inf.entity_id, inf.to, essence);
  };

  this._removeEntity = function(inf) {
    Action.PlaceEntity.remove(inf.entity_id, essence);
  };

  this._init();
}
