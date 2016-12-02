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
end
