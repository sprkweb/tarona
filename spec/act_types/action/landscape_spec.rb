describe Tarona::Action::Landscape do
  let(:landscape) { described_class.new }

  it 'allows to add places' do
    place = landscape.add([3, 0])[0]
    expect(place).to eq({})
    expect(landscape.get(3, 0)).to eq(place)
  end

  it 'returns nil when there is no requested place' do
    expect(landscape.get(5, 5)).to be nil
  end

  it 'cleans the place if it is added again' do
    landscape.add([3, 0])[0]['old'] = true
    expect(landscape.add([3, 0])).to eq([{}])
  end

  it 'can add many places at once' do
    places = [[0, 1], [1, 0], [5, 5]]
    result = landscape.add(*places)
    expect(result).to eq([{}, {}, {}])
    places.each do |place|
      expect(landscape.get(*place)).to eq({})
    end
  end

  describe '#neighbors' do
    it 'can list you neighbors of a place' do
      landscape.add [3, 3], [4, 4], [4, 3]
      expect(landscape.neighbors(3, 3)).to eq([[4, 3], [4, 4]])
    end

    it 'returns empty array when there are no neighbors' do
      expect(landscape.neighbors(3, 3)).to eq([])
    end

    it 'does not return the place itself' do
      landscape.add [3, 3]
      expect(landscape.neighbors(3, 3)).to eq([])
    end

    it 'does not return neighbors when there is no place' do
      landscape.add([3, 3])
      expect(landscape.neighbors(3, 4)).to eq([])
    end

    it 'returns neighbors only' do
      landscape.add [3, 3], [3, 2], [10, 30]
      expect(landscape.neighbors(3, 3)).to eq([[3, 2]])
    end

    example do
      # [rows_numbers, columns_numbers]
      size = [0..5, 0..5]
      places = size[0].inject([]) do |result, row|
        result + size[1].map { |col| [row, col] }
      end
      landscape.add(*places)
      expected_neighbors = [[1, 1], [1, 2], [1, 3], [2, 1], [2, 3], [3, 2]]
      expect(landscape.neighbors(2, 2)).to eq(expected_neighbors)
    end
  end

  it 'can be created from an array' do
    arr = [[:a, :b], [:c, :d]]
    subj = described_class.new arr
    expect(subj.get(0, 1)).to be(:b)
  end

  it 'can return its raw version' do
    landscape.add([0, 0], [0, 1], [1, 0], [1, 1])
    expect(landscape.raw).to eq([[{}, {}], [{}, {}]])
  end
end
