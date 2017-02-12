describe('Action.EntitiesGrid', function() {
  it('wraps the given grid', function() {
    var grid = [[], []];
    var subj = new Action.EntitiesGrid(grid);
    expect(subj.grid).toBe(grid);
  });

  it('can start from empty grid', function() {
    var subj = new Action.EntitiesGrid();
    expect(subj.grid).toEqual([]);
  });

  var entity, entity2;
  beforeEach(function() {
    entity = { id: 'entity' };
    entity2 = { id: 'entity2' };
  });

  describe('#get', function() {
    it('returns entities from the given place', function() {
      var subj = new Action.EntitiesGrid([undefined, [[entity, entity2]]]);
      expect(subj.get([1, 0])).toEqual([entity, entity2]);
    });

    it('returns entities only from the given place', function() {
      var subj = new Action.EntitiesGrid([[undefined, [entity]], [[entity2]]]);
      expect(subj.get([0, 1])).toEqual([entity]);
    });

    it('returns empty array when there is no such place', function() {
      var subj = new Action.EntitiesGrid([[[entity]]]);
      expect(subj.get([3, 2])).toEqual([]);
    });

    it('does not create new place when there is no such place', function() {
      var subj = new Action.EntitiesGrid();
      expect(subj.get([3, 2])).toEqual([]);
      expect(subj.grid).toEqual([]);
    });
  });

  describe('#add', function() {
    beforeEach(function() {
      entity.hexes = function() { return [[1, 2], [1, 1]] };
      entity2.hexes = function() { return [[1, 2], [0, 1]] };
      spyOn(entity, 'hexes').and.callThrough();
      spyOn(entity2, 'hexes').and.callThrough();
    });

    it('adds entity to the given place', function() {
      var subj = new Action.EntitiesGrid();
      subj.add([0, 2], entity);
      expect(entity.hexes).toHaveBeenCalledWith([0, 2]);
      expect(subj.grid).toEqual([undefined, [undefined, [entity], [entity]]]);
    });

    it('can add many entities to the same place', function() {
      var subj = new Action.EntitiesGrid();
      subj.add([1, 2], entity);
      subj.add([1, 2], entity2);
      expect(entity.hexes).toHaveBeenCalledWith([1, 2]);
      expect(entity2.hexes).toHaveBeenCalledWith([1, 2]);
      expect(subj.grid).toEqual(
        [[undefined, [entity2]], [undefined, [entity], [entity, entity2]]]);
    });
  });

  describe('#remove', function() {
    beforeEach(function() {
      entity.hexes = function() { return [[3, 2], [3, 1]] };
      entity2.hexes = function() { return [[3, 2], [3, 3]] };
      spyOn(entity, 'hexes').and.callThrough();
      spyOn(entity2, 'hexes').and.callThrough();
    });

    it('removes entity from the given place', function() {
      var subj = new Action.EntitiesGrid();
      subj.add([3, 2], entity);
      subj.remove([3, 2], entity);
      expect(subj.get([3, 2])).toEqual([]);
      expect(subj.get([3, 1])).toEqual([]);
    });

    it('returns true if remove is successful', function() {
      var subj = new Action.EntitiesGrid();
      subj.add([3, 2], entity);
      expect(subj.remove([3, 2], entity)).toBeTruthy();
    });

    it('removes only given entity', function() {
      var subj = new Action.EntitiesGrid();
      subj.add([3, 2], entity);
      subj.add([3, 2], entity2);
      expect(subj.remove([3, 2], entity)).toBeTruthy();
      expect(subj.get([3, 1])).toEqual([]);
      expect(subj.get([3, 2])).toEqual([entity2]);
      expect(subj.get([3, 3])).toEqual([entity2]);
    });

    it('removes entity only from the given place', function() {
      var subj = new Action.EntitiesGrid();
      subj.grid = [[[entity]], [[], [entity]], [], [[], [entity], [entity]]];
      expect(subj.remove([3, 2], entity)).toBeTruthy();
      expect(subj.get([0, 0])).toEqual([entity]);
      expect(subj.get([1, 1])).toEqual([entity]);
    });

    it('returns false if there is no such entity', function() {
      var subj = new Action.EntitiesGrid();
      expect(subj.remove([3, 2], entity)).toEqual(false);
    });

    it('returns false if entity is removed from a part of places', function() {
      var subj = new Action.EntitiesGrid();
      subj.grid = [[], [], [], [[], [], [entity]]];
      expect(subj.remove([3, 2], entity)).toEqual(false);
    });
  });
});
