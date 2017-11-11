describe('PlaceEntity', function() {
  var essence, entity;

  beforeEach(function() {
    entity = {
      id: 'deadbeef',
      coordinates: [3, 2],
      move: jasmine.createSpy('move'),
      remove: jasmine.createSpy('remove')
    };
    essence = {
      entities_grid: {
        add: jasmine.createSpy('entities_grid#add'),
        remove: jasmine.createSpy('entities_grid#remove')
      },
      entities: { deadbeef: entity },
      entitiesElem: {
        appendChild: jasmine.createSpy('entitiesElem#appendChild')
      },
      hex: new Action.Hex(25)
    };
  });

  describe('#add', function() {
    it('creates entity object', function() {
      Action.PlaceEntity.add({ id: 'baz', foo: 'bar' }, [5, 1], essence);
      var entity = essence.entities.baz;
      expect(entity.options)
        .toEqual({ id: 'baz', foo: 'bar', place: [5, 1], hex: essence.hex });
    });

    it('adds entity to the act', function() {
      Action.PlaceEntity.add({ id: 'baz', foo: 'bar' }, [5, 1], essence);
      var entity = essence.entities.baz;
      expect(essence.entities_grid.add).toHaveBeenCalledWith([5, 1], entity);
      expect(essence.entitiesElem.appendChild)
        .toHaveBeenCalledWith(entity.elem);
    });

    it('does not add entity when there is no entity id', function() {
      Action.PlaceEntity.add({ foo: 'bar' }, [5, 1], essence);
      expect(essence.entities.baz).toBe(undefined);
      expect(essence.entities_grid.add).not.toHaveBeenCalled();
      expect(essence.entitiesElem.appendChild).not.toHaveBeenCalled();
    });

    it('does not add entity when there is no place', function() {
      Action.PlaceEntity.add({ id: 'baz', foo: 'bar' }, null, essence);
      expect(essence.entities.baz).toBe(undefined);
      expect(essence.entities_grid.add).not.toHaveBeenCalled();
      expect(essence.entitiesElem.appendChild).not.toHaveBeenCalled();
    });
  });

  describe('#move', function() {
    it('moves entity', function() {
      Action.PlaceEntity.move('deadbeef', [5, 6], essence);
      expect(essence.entities_grid.remove).toHaveBeenCalledWith([3, 2], entity);
      expect(essence.entities_grid.add).toHaveBeenCalledWith([5, 6], entity);
      expect(entity.move).toHaveBeenCalledWith([5, 6], true);
    });

    it('does not move entity without target', function() {
      Action.PlaceEntity.move('deadbeef', null, essence);
      expect(essence.entities_grid.remove).not.toHaveBeenCalled();
      expect(essence.entities_grid.add).not.toHaveBeenCalled();
      expect(entity.move).not.toHaveBeenCalled();
    });

    it('does not move entity without entity', function() {
      Action.PlaceEntity.move('livebeef', [5, 6], essence);
      expect(essence.entities_grid.remove).not.toHaveBeenCalled();
      expect(essence.entities_grid.add).not.toHaveBeenCalled();
      expect(entity.move).not.toHaveBeenCalled();
    });
  });

  describe('#remove', function() {
    it('removes entity', function() {
      Action.PlaceEntity.remove('deadbeef', essence);
      expect(essence.entities_grid.remove).toHaveBeenCalledWith([3, 2], entity);
      expect(entity.remove).toHaveBeenCalled();
      expect(essence.entities.deadbeef).toEqual(undefined);
    });

    it('does not remove entity without entity', function() {
      Action.PlaceEntity.remove('livebeef', essence);
      expect(essence.entities_grid.remove).not.toHaveBeenCalled();
      expect(entity.remove).not.toHaveBeenCalled();
      expect(essence.entities.deadbeef).toEqual(entity);
    });
  });
});
