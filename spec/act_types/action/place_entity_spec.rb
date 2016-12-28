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
      matrix[x][y]
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
end
