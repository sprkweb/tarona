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
end
