RSpec.describe Tarona::Action::Pathfinder::FindPath do
  let(:entity) { double }
  let(:ai) { double }
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  before :each do
    allow(entity).to receive(:ai) { ai }
    allow(ai).to receive(:obstacles?) { false }
  end

  it 'can find the simplest straight path' do
    # "O" is ground, "A" is start, "B" is finish
    # A O O  | 0
    #  O O O | 1
    # O O O  | 2
    #  O B O | 3
    # -------| ^ y coordinates
    # 001122 <= x coordinates
    path = described_class.call(
      map: map, entity: entity, from: [0, 0], to: [1, 3]
    )
    expect(path.result).to eq(
      found: true,
      path: [[0, 0], [0, 1], [1, 2], [1, 3]],
      costs: {
        [0, 0] => { total: 0, last: 0 },
        [0, 1] => { total: 1, last: 1 },
        [1, 2] => { total: 2, last: 1 },
        [1, 3] => { total: 3, last: 1 }
      }
    )
  end

  it 'can find the shortest path with obstacles' do
    # "O" is ground, "%" is mountain, "A" is start, "B" is finish
    # O O O O B O  | 0
    #  O O O O O O | 1
    # % % % % % O  | 2
    #  O O O % O O | 3
    # O A O % O O  | 4
    #  O O % O O O | 5
    # O O O O O O  | 6
    # -------------| ^ y coordinates
    # 001122334455 <= x coordinates
    allow(ai).to receive(:obstacles?) do |here|
      mountains = [
        [0, 2], [1, 2], [2, 2], [3, 2],
        [4, 2], [3, 3], [3, 4], [2, 5]
      ]
      mountains.include? here
    end
    path = described_class.call(
      map: map, entity: entity, from: [1, 4], to: [4, 0]
    )
    expect(path.result).to eq(
      found: true,
      path: [
        [1, 4], [1, 5], [2, 6], [3, 6], [3, 5],
        [4, 4], [4, 3], [5, 2], [4, 1], [4, 0]
      ],
      costs: {
        [1, 4] => { total: 0, last: 0 }, [1, 5] => { total: 1, last: 1 },
        [2, 6] => { total: 2, last: 1 }, [3, 6] => { total: 3, last: 1 },
        [3, 5] => { total: 4, last: 1 }, [4, 4] => { total: 5, last: 1 },
        [4, 3] => { total: 6, last: 1 }, [5, 2] => { total: 7, last: 1 },
        [4, 1] => { total: 8, last: 1 }, [4, 0] => { total: 9, last: 1 }
      }
    )
  end

  it 'can not find path if there is no path' do
    # "O" is ground, "%" is mountain, "A" is start, "B" is finish
    # O O O B O  | 0
    #  % % % % O | 1
    # O A O % O  | 2
    #  O O % O O | 3
    # % % % O O  | 4
    # -----------| ^ y coordinates
    # 0011223344 <= x coordinates
    allow(ai).to receive(:obstacles?) do |here|
      mountains = [
        [0, 1], [1, 1], [2, 1], [3, 1], [3, 2], [2, 3], [2, 4], [0, 4], [1, 4]
      ]
      mountains.include? here
    end
    path = described_class.call(
      map: map, entity: entity, from: [1, 2], to: [3, 0]
    )
    expect(path.result).to eq(found: false)
  end

  it 'can not find path if the given start does not exist' do
    path = described_class.call(
      map: map, entity: entity, from: [999, 2], to: [3, 2]
    )
    expect(path.result).to eq(found: false)
  end

  it 'can not find path if the given finish does not exist' do
    path = described_class.call(
      map: map, entity: entity, from: [0, 2], to: [20, 2]
    )
    expect(path.result).to eq(found: false)
  end
end
