RSpec.describe Tarona::Action::Catalyst do
  let :landscape do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:entity) { double }
  let(:get_places) { double }
  let(:places) { [] }
  let(:subj) { described_class.new get_places, landscape }

  describe '#places_exist?' do
    it 'returns true if all of the entity\'s places exist' do
      expect(get_places).to receive(:call)
        .with(entity, [3, 2]).and_return([[0, 0], [3, 2], [9, 9]])
      expect(subj.places_exist?(entity, [3, 2])).to be true
    end

    it 'returns true if entity does not take places' do
      expect(get_places).to receive(:call).with(entity, [5, 3]).and_return([])
      expect(subj.places_exist?(entity, [5, 3])).to be true
    end

    it 'returns false if one of the places does not exist' do
      expect(get_places).to receive(:call)
        .with(entity, [3, 2]).and_return([[0, 0], [3, 2], [10, 9]])
      expect(subj.places_exist?(entity, [3, 2])).to be false
    end

    it 'returns false if all places do not exist' do
      expect(get_places).to receive(:call)
        .with(entity, [3, 2]).and_return([[99, 99], [13, 2], [0, 55]])
      expect(subj.places_exist?(entity, [3, 2])).to be false
    end

    it 'returns false for negative coordinates' do
      expect(get_places).to receive(:call)
        .with(entity, [3, 2]).and_return([[-1, -2], [0, 2]])
      expect(subj.places_exist?(entity, [3, 2])).to be false
    end
  end
end
