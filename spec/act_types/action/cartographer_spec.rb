RSpec.describe Tarona::Action::Cartographer do
  let(:modul) { described_class }

  describe '#distance' do
    it 'returns distance between given points' do
      needed_results = {
        [[1, 2], [4, 4]] => 4,
        [[0, 0], [1, 2]] => 2,
        [[135, 5], [135, 5]] => 0,
        [[7, 5], [7, 4]] => 1,
        [[0, 0], [0, 0]] => 0
      }
      needed_results.each do |args, result|
        expect(modul.distance(*args)).to be(result)
      end
    end
  end

  describe '#line' do
    it 'return points of line between two given places' do
      needed_results = {
        [[2, 2], [5, 4]] => [[2, 2], [3, 2], [3, 3], [4, 3], [5, 4]],
        [[2, 2], [3, 1]] => [[2, 2], [3, 2], [3, 1]],
        [[5, 4], [1, 3]] => [[5, 4], [4, 4], [3, 3], [2, 3], [1, 3]],
        [[7, 5], [7, 4]] => [[7, 5], [7, 4]],
        [[1, 3], [1, 3]] => [[1, 3]]
      }
      needed_results.each do |args, result|
        expect(modul.line(*args)).to eq(result)
      end
    end
  end
end
