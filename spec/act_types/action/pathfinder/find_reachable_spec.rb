RSpec.describe Tarona::Action::Pathfinder::FindReachable do
  let(:entity) { double }
  let(:catalyst) { double }
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  before :each do
    allow(catalyst).to receive(:call) { true }
    allow(entity).to receive(:move_cost) { 1 }
  end

  it 'can find reachable places' do
    map = Tarona::Action::Landscape.new(Array.new(2) { Array.new(3) { {} } })
    reachable = described_class.call(
      map: map, entity: entity, from: [0, 0], catalyst: catalyst
    )
    expect(reachable.result).to eq(
      places: {
        [0, 0] => nil,    [1, 0] => [0, 0], [0, 1] => [0, 0],
        [1, 1] => [1, 0], [1, 2] => [0, 1], [0, 2] => [0, 1]
      },
      costs: {
        [0, 0] => 0,      [1, 0] => 1,      [0, 1] => 1,
        [1, 1] => 2,      [1, 2] => 2,      [0, 2] => 2
      }
    )
  end

  it 'can find reachable places with obstacles' do
    # "O" is ground, "%" is mountain, "A" is start
    # O O % O O %  | 0
    #  O % A O % O | 1
    # O % % % % O  | 2
    # -------------| ^ y coordinates
    # 001122334455 <= x coordinates
    allow(catalyst).to receive(:call) do |_, here|
      ![
        [2, 0], [5, 0], [1, 1], [4, 1], [1, 2], [2, 2], [3, 2], [4, 2]
      ].include?(here)
    end
    reachable = described_class.call(
      map: map, from: [2, 1], entity: entity, catalyst: catalyst
    )
    expect(reachable.result).to eq(
      places: {
        [2, 1] => nil, [3, 0] => [2, 1], [3, 1] => [2, 1], [4, 0] => [3, 1]
      },
      costs: {
        [2, 1] => 0, [3, 0] => 1, [3, 1] => 1, [4, 0] => 2
      }
    )
  end

  it 'can receive movement cost limit' do
    # "O" is ground, "%" is mountain, "A" is start
    # O A % O O O  | 0
    #  O O O O O O | 1
    # O O O O O O  | 2
    # -------------| ^ y coordinates
    # 001122334455 <= x coordinates
    allow(catalyst).to receive(:call) { |_, here| [2, 0] != here }
    reachable = described_class.call(
      map: map, from: [1, 0], entity: entity, max_cost: 2, catalyst: catalyst
    )
    expect(reachable.result).to eq(
      places: {
        [1, 0] => nil,    [0, 0] => [1, 0], [0, 1] => [1, 0], [1, 1] => [1, 0],
        [0, 2] => [0, 1], [1, 2] => [1, 1], [2, 2] => [1, 1], [2, 1] => [1, 1]
      },
      costs: {
        [1, 0] => 0,      [0, 0] => 1,      [0, 1] => 1,      [1, 1] => 1,
        [0, 2] => 2,      [1, 2] => 2,      [2, 2] => 2,      [2, 1] => 2
      }
    )
  end

  it 'finds nothing if start does not exists' do
    reachable = described_class.call(
      map: map, entity: entity, from: [999, 999], catalyst: catalyst
    )
    expect(reachable.result).to eq places: {}, costs: {}
  end

  it 'finds only start if move_cost is zero' do
    reachable = described_class.call(
      map: map, entity: entity, from: [3, 2], max_cost: 0, catalyst: catalyst
    )
    expect(reachable.result).to eq(
      places: { [3, 2] => nil },
      costs: { [3, 2] => 0 }
    )
  end

  context 'with different movement costs' do
    Ground = Struct.new :cost
    before :each do
      allow(entity).to receive(:move_cost) do |from, to|
        from.cost + to.cost
      end
    end

    it 'can find the stortest paths' do
      # "%" is mountain, "A" is start, digit is ground's movement cost
      # 0 A % 3 4 5  | 0
      #  % 1 9 3 4 5 | 1
      # 0 1 2 3 4 5  | 2
      # -------------| ^ y coordinates
      # 001122334455 <= x coordinates
      map = Tarona::Action::Landscape.new(
        Array.new(6) do |i|
          Array.new(3) { { g: Ground.new(i) } }
        end
      )
      map.get(2, 1)[:g] = Ground.new(9)
      allow(catalyst).to receive(:call) do |_, here|
        ![[2, 0], [0, 1]].include?(here)
      end
      reachable = described_class.call(
        map: map, from: [1, 0], entity: entity, max_cost: 24, catalyst: catalyst
      )
      expect(reachable.result).to eq(
        places: {
          [1, 0] => nil,    [0, 0] => [1, 0], [1, 1] => [1, 0],
          [1, 2] => [1, 1], [0, 2] => [1, 2], [2, 2] => [1, 1],
          [3, 2] => [2, 2], [3, 1] => [3, 2], [3, 0] => [3, 1],
          [4, 0] => [3, 1], [4, 1] => [3, 1], [4, 2] => [3, 2],
          [2, 1] => [1, 1]
        },
        costs: {
          [1, 0] => 0,  [0, 0] => 1,  [1, 1] => 2,
          [1, 2] => 4,  [0, 2] => 5,  [2, 2] => 5,
          [3, 2] => 10, [3, 1] => 16, [3, 0] => 22,
          [4, 0] => 23, [4, 1] => 23, [4, 2] => 17,
          [2, 1] => 12
        }
      )
    end
  end
end
