RSpec.describe Tarona::Action::Pathfinder::FindReachable do
  let(:entity) { double }
  let(:ai) { double }
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  before :each do
    allow(entity).to receive(:ai) { ai }
    allow(ai).to receive(:obstacles?) { false }
  end

  it 'can find reachable places' do
    map = Tarona::Action::Landscape.new(Array.new(2) { Array.new(3) { {} } })
    reachable = described_class.call map: map, from: [0, 0]
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
    allow(ai).to receive(:obstacles?) do |here|
      [
        [2, 0], [5, 0], [1, 1], [4, 1], [1, 2], [2, 2], [3, 2], [4, 2]
      ].include? here
    end
    reachable = described_class.call map: map, from: [2, 1], entity: entity
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
    allow(ai).to receive(:obstacles?) { |here| [2, 0] == here }
    reachable = described_class.call(
      map: map, from: [1, 0], entity: entity, max_cost: 2
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

  it 'does not raises error if entity does not have AI' do
    # "O" is ground, "A" is start
    # O O O O O O  | 0
    #  A O O O O O | 1
    # O O O O O O  | 2
    # -------------| ^ y coordinates
    # 001122334455 <= x coordinates
    reachable = described_class.call(
      map: map, from: [0, 1], entity: double, max_cost: 1
    )
    expect(reachable.result).to eq(
      places: {
        [0, 1] => nil,    [0, 0] => [0, 1], [1, 0] => [0, 1],
        [1, 1] => [0, 1], [0, 2] => [0, 1], [1, 2] => [0, 1]
      },
      costs: {
        [0, 1] => 0,      [0, 0] => 1,      [1, 0] => 1,
        [1, 1] => 1,      [0, 2] => 1,      [1, 2] => 1
      }
    )
  end

  it 'finds nothing if start does not exists' do
    reachable = described_class.call map: map, from: [999, 999]
    expect(reachable.result).to eq places: {}, costs: {}
  end

  it 'finds only start if move_cost is zero' do
    reachable = described_class.call map: map, from: [3, 2], max_cost: 0
    expect(reachable.result).to eq(
      places: { [3, 2] => nil },
      costs: { [3, 2] => 0 }
    )
  end
end
