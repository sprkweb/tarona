RSpec.describe Tarona::Action::PlaceEntity do
  let(:modul) { Tarona::Action::PlaceEntity }

  describe '#abs_hexes' do
    it 'converts relative coordinates to absolute' do
      offset = [[0, 0], [-1, 1]]
      center = [5, 5]
      absolute = [[5, 5], [4, 6]]
      expect(modul.abs_hexes(offset, center)).to eq(absolute)
    end
  end

  describe '#places_taken' do
    let(:ent) { double }

    before :each do
      allow(ent).to receive(:hexes)
        .and_return(even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 0]])
    end

    it 'says what places does the entity takes when it is placed here' do
      expect(modul.places_taken(entity, [5, 4])).to eq([[5, 4], [5, 5]])
      expect(modul.places_taken(entity, [5, 5])).to eq([[5, 5], [6, 5]])
    end
  end

  let(:matrix) { Array.new(7) { Array.new(7) { {} } } }
  let(:landscape) { double 'landscape' }
  let(:entity) { double 'entity' }
  let(:entity2) { double 'entity2' }
  before :each do
    allow(landscape).to receive(:get) do |x, y|
      matrix[x][y] if matrix[x]
    end
    allow(entity).to receive(:hexes)
      .and_return(even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 0]])
    allow(entity2).to receive(:hexes)
      .and_return(even_row: [[1, 1]], odd_row: [[-1, -1]])
  end

  describe '#add' do
    it 'adds entity object to its places' do
      modul.add landscape, entity, [2, 3]
      expect(matrix[2][3][:e]).to eq([entity])
      expect(matrix[3][3][:e]).to eq([entity])
    end

    context 'when entity\'s y coordinate is even' do
      it 'adds entity object to its places' do
        modul.add landscape, entity, [2, 4]
        expect(matrix[2][4][:e]).to eq([entity])
        expect(matrix[2][5][:e]).to eq([entity])
      end
    end

    it 'adds entity object even if there is another one' do
      modul.add landscape, entity, [2, 3]
      expect(matrix[2][3][:e]).to eq([entity])
      modul.add landscape, entity2, [1, 2]
      expect(matrix[2][3][:e]).to eq([entity, entity2])
    end

    it 'returns given entity' do
      result = modul.add landscape, entity, [2, 3]
      expect(result).to be(entity)
    end
  end

  describe '#remove' do
    it 'deletes entity object from all of its places' do
      modul.add landscape, entity, [2, 3]
      modul.remove landscape, entity, [2, 3]
      expect(matrix[2][3][:e]).to be nil
      expect(matrix[3][3][:e]).to be nil
    end

    context 'when entity\'s y coordinate is even' do
      it 'deletes entity object from all of its places' do
        modul.add landscape, entity, [2, 4]
        modul.remove landscape, entity, [2, 4]
        expect(matrix[2][4][:e]).to be nil
        expect(matrix[2][5][:e]).to be nil
      end
    end

    it 'deletes only the given entity' do
      modul.add landscape, entity, [2, 3]
      modul.add landscape, entity2, [1, 2]
      modul.remove landscape, entity, [2, 3]
      expect(matrix[2][3][:e]).to eq([entity2])
      expect(matrix[3][3][:e]).to be nil
    end

    it 'returns given entity' do
      modul.add landscape, entity, [2, 3]
      result = modul.remove landscape, entity, [2, 3]
      expect(result).to be(entity)
    end
  end

  describe '#move' do
    it 'moves entity object' do
      modul.add landscape, entity, [2, 3]
      modul.move landscape, entity, [2, 3], [3, 2]
      expect(matrix[2][3][:e]).to be nil
      expect(matrix[3][2][:e]).to eq([entity])
      expect(matrix[3][3][:e]).to eq([entity])
    end

    context 'when entity\'s y coordinate is even' do
      it 'moves entity object' do
        modul.add landscape, entity, [3, 2]
        modul.move landscape, entity, [3, 2], [2, 3]
        expect(matrix[2][3][:e]).to eq([entity])
        expect(matrix[3][2][:e]).to be nil
        expect(matrix[3][3][:e]).to eq([entity])
      end
    end

    it 'moves only the given entity' do
      allow(entity).to receive(:hexes)
        .and_return(even_row: [[0, 0], [1, -1]], odd_row: [[0, 0], [1, 0]])
      allow(entity2).to receive(:hexes)
        .and_return(even_row: [[1, 1], [2, 1]], odd_row: [[-1, -1], [-1, 0]])
      modul.add landscape, entity, [2, 3]
      modul.add landscape, entity2, [1, 2]
      modul.move landscape, entity, [2, 3], [2, 4]
      expect(matrix[2][3][:e]).to eq([entity2])
      expect(matrix[3][3][:e]).to eq([entity2, entity])
      expect(matrix[2][4][:e]).to eq([entity])
    end

    it 'cleans entity containers if they are becoming empty' do
      modul.add landscape, entity, [2, 3]
      modul.move landscape, entity, [2, 3], [2, 4]
      expect(matrix[2][3][:e]).to be nil
    end

    it 'returns given entity' do
      modul.add landscape, entity, [2, 3]
      result = modul.move landscape, entity, [2, 3], [2, 3]
      expect(result).to be(entity)
    end
  end

  describe '#find' do
    let(:entities_index) { {} }
    before :each do
      allow(entity).to receive(:id).and_return(:foo)
      allow(entity2).to receive(:id).and_return(:bar)
    end

    it 'returns entity object' do
      entities_index[:foo] = [4, 5]
      matrix[4][5] = { e: [entity] }
      expect(modul.find(landscape, entities_index, :foo)).to be entity
    end

    it 'returns nil if entity is not in index' do
      matrix[4][5] = { e: [entity] }
      expect(modul.find(landscape, entities_index, :foo)).to be nil
    end

    it 'returns nil if entity is not on the map' do
      entities_index[:foo] = [4, 5]
      matrix[4][5] = { e: [] }
      expect(modul.find(landscape, entities_index, :foo)).to be nil
    end

    it 'returns nil if there is no such place' do
      entities_index[:foo] = [13, 9]
      matrix[4][5] = { e: [entity] }
      expect(modul.find(landscape, entities_index, :foo)).to be nil
    end

    it 'returns nil if there there is no entities at the place' do
      entities_index[:foo] = [4, 5]
      expect(modul.find(landscape, entities_index, :foo)).to be nil
    end

    it 'can work with many entities at the place' do
      entities_index[:foo] = [3, 2]
      entities_index[:bar] = [3, 2]
      matrix[3][2] = { e: [entity, entity2] }
      expect(modul.find(landscape, entities_index, :bar)).to be entity2
    end
  end

  describe '#distance' do
    entity_class = Struct.new(:id, :hexes)
    let :entity3 do
      entity_class.new(
        :entity3,
        even_row: [[0, 0], [0, -1], [1, -2]],
        odd_row: [[0, 0], [1, -1], [1, -2]]
      )
    end
    let :entity4 do
      entity_class.new(
        :entity4,
        even_row: [[0, 0], [0, 1]], odd_row: [[0, 0], [1, 1]]
      )
    end
    let :entity5 do
      entity_class.new(
        :entity5,
        even_row: [[0, 0], [-1, 0]], odd_row: [[0, 0], [-1, 0]]
      )
    end

    let(:index) { { entity3: [3, 4], entity4: [3, 3], entity5: [6, 0] } }

    it 'returns distance between two nearest parts of entities' do
      expect(modul.distance(index, entity3, entity5)).to eq(2)
    end

    it 'returns 1 when they stand alongside' do
      index[:entity4] = [2, 2]
      expect(modul.distance(index, entity3, entity4)).to eq(1)
    end

    it 'returns 0 when entities are on the same place' do
      expect(modul.distance(index, entity3, entity4)).to eq(0)
    end
  end
end
