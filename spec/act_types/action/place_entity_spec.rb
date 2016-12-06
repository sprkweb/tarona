RSpec.describe Tarona::Action::PlaceEntity do
  let(:modul) { Tarona::Action::PlaceEntity }

  describe '#abs_hexes' do
    it 'says what places does the entity takes when it is placed here' do
      offset = [[0, 0], [-1, 1]]
      center = [5, 5]
      absolute = [[5, 5], [4, 6]]
      expect(modul.abs_hexes(offset, center)).to eq(absolute)
    end
  end

  let(:landscape) { double 'landscape' }
  let(:place) { {} }
  let(:place2) { {} }
  let(:place3) { {} }
  let(:entity) { double 'entity' }
  let(:entity2) { double 'entity2' }
  before :each do
    allow(landscape).to receive(:get).with(0, 0) { place }
    allow(landscape).to receive(:get).with(2, 3) { place }
    allow(landscape).to receive(:get).with(2, 4) { place2 }
    allow(landscape).to receive(:get).with(2, 5) { place3 }
    allow(entity).to receive(:hexes) { [[0, 0], [0, 1]] }
    allow(entity2).to receive(:hexes) { [[1, 1]] }
  end

  describe '#add' do
    it 'adds entity object to its places' do
      modul.add landscape, entity, [2, 3]
      expect(place[:e]).to eq([entity])
      expect(place2[:e]).to eq([entity])
    end

    it 'adds entity object even if there is another one' do
      modul.add landscape, entity, [2, 3]
      expect(place[:e]).to eq([entity])
      modul.add landscape, entity2, [1, 2]
      expect(place[:e]).to eq([entity, entity2])
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
      expect(place[:e]).to be nil
      expect(place2[:e]).to be nil
    end

    it 'deletes only the given entity' do
      modul.add landscape, entity, [2, 3]
      modul.add landscape, entity2, [1, 2]
      modul.remove landscape, entity, [2, 3]
      expect(place[:e]).to eq([entity2])
      expect(place2[:e]).to be nil
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
      modul.move landscape, entity, [2, 3], [2, 4]
      expect(place[:e]).to be nil
      expect(place2[:e]).to eq([entity])
      expect(place3[:e]).to eq([entity])
    end

    it 'moves only the given entity' do
      allow(entity2).to receive(:hexes) { [[1, 1], [1, 2]] }
      modul.add landscape, entity, [2, 3]
      modul.add landscape, entity2, [1, 2]
      modul.move landscape, entity, [2, 3], [2, 4]
      expect(place[:e]).to eq([entity2])
      expect(place2[:e]).to eq([entity2, entity])
      expect(place3[:e]).to eq([entity])
    end

    it 'cleans entity containers if they are becoming empty' do
      modul.add landscape, entity, [2, 3]
      modul.move landscape, entity, [2, 3], [2, 4]
      expect(place[:e]).to be nil
      expect(place2[:e]).to eq([entity])
      expect(place3[:e]).to eq([entity])
    end

    it 'returns given entity' do
      modul.add landscape, entity, [2, 3]
      result = modul.move landscape, entity, [2, 3], [2, 3]
      expect(result).to be(entity)
    end
  end
end
