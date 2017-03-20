RSpec.describe Tarona::Action::Pathfinder::FindPath do
  let(:entity) { double }
  let(:catalyst) { double }

  GROUND_NAMES = [:stone, :ground, :grass, :sand, :water].freeze
  GROUND_TYPES = GROUND_NAMES.each_with_object({}) { |t, h| h[t] = Object.new }
  get_row = proc do |type|
    Array.new(10) { { g: GROUND_TYPES[type] } }
  end
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) do |i|
      get_row.call(GROUND_NAMES[i % 5])
    end)
  end

  before :each do
    allow(catalyst).to receive(:call) { true }
    allow(entity).to receive(:move_cost) { 1 }
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
      map: map, entity: entity, from: [0, 0], to: [1, 3], catalyst: catalyst
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
    allow(catalyst).to receive(:call) do |_, here|
      mountains = [
        [0, 2], [1, 2], [2, 2], [3, 2],
        [4, 2], [3, 3], [3, 4], [2, 5]
      ]
      !mountains.include?(here)
    end
    path = described_class.call(
      map: map, entity: entity, from: [1, 4], to: [4, 0], catalyst: catalyst
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
    allow(catalyst).to receive(:call) do |_, here|
      mountains = [
        [0, 1], [1, 1], [2, 1], [3, 1], [3, 2], [2, 3], [2, 4], [0, 4], [1, 4]
      ]
      !mountains.include?(here)
    end
    path = described_class.call(
      map: map, entity: entity, from: [1, 2], to: [3, 0], catalyst: catalyst
    )
    expect(path.result).to eq(found: false)
  end

  it 'can not find path if the given start does not exist' do
    path = described_class.call(
      map: map, entity: entity, from: [999, 2], to: [3, 2], catalyst: catalyst
    )
    expect(path.result).to eq(found: false)
  end

  it 'can not find path if the given finish does not exist' do
    path = described_class.call(
      map: map, entity: entity, from: [0, 2], to: [20, 2], catalyst: catalyst
    )
    expect(path.result).to eq(found: false)
  end

  context 'with different movement costs' do
    cell_cost = proc do |type|
      GROUND_NAMES.index(GROUND_TYPES.key(type)) + 1
    end
    before :each do
      allow(entity).to receive(:move_cost) do |from, to|
        cell_cost.call(from) + cell_cost.call(to)
      end
    end

    it 'can find the simplest straight path' do
      # A" is start, "B" is finish, digit is ground's movement cost
      # A 2 3  | 0
      #  1 2 3 | 1
      # 1 2 3  | 2
      #  1 B 3 | 3
      # -------| ^ y coordinates
      # 001122 <= x coordinates
      path = described_class.call(
        map: map, entity: entity, from: [0, 0], to: [1, 3], catalyst: catalyst
      )
      expect(path.result).to eq(
        found: true,
        path: [[0, 0], [0, 1], [1, 2], [1, 3]],
        costs: {
          [0, 0] => { total: 0, last: 0 },
          [0, 1] => { total: 2, last: 2 },
          [1, 2] => { total: 5, last: 3 },
          [1, 3] => { total: 9, last: 4 }
        }
      )
    end

    it 'can find the fastest path with obstacles' do
      # "%" is mountain, "A" is start, "B" is finish,
      # digit is ground's movement cost
      # 1 2 3 4 B 1  | 0
      #  1 2 3 4 5 1 | 1
      # % % % % % 1  | 2
      #  1 2 3 % 5 1 | 3
      # 1 A 3 % 5 1  | 4
      #  1 2 % 4 5 1 | 5
      # 1 2 3 4 5 1  | 6
      # -------------| ^ y coordinates
      # 001122334455 <= x coordinates
      allow(catalyst).to receive(:call) do |_, here|
        mountains = [
          [0, 2], [1, 2], [2, 2], [3, 2],
          [4, 2], [3, 3], [3, 4], [2, 5]
        ]
        !mountains.include?(here)
      end
      path = described_class.call(
        map: map, entity: entity, from: [1, 4], to: [4, 0], catalyst: catalyst
      )
      expect(path.result).to eq(
        found: true,
        path: [
          [1, 4], [1, 5], [2, 6], [3, 6], [4, 6], [5, 6], [5, 5],
          [5, 4], [5, 3], [5, 2], [5, 1], [5, 0], [4, 0]
        ],
        costs: {
          [1, 4] => { total: 0, last: 0 },  [1, 5] => { total: 4, last: 4 },
          [2, 6] => { total: 9, last: 5 },  [3, 6] => { total: 16, last: 7 },
          [4, 6] => { total: 25, last: 9 }, [5, 6] => { total: 31, last: 6 },
          [5, 5] => { total: 33, last: 2 }, [5, 4] => { total: 35, last: 2 },
          [5, 3] => { total: 37, last: 2 }, [5, 2] => { total: 39, last: 2 },
          [5, 1] => { total: 41, last: 2 }, [5, 0] => { total: 43, last: 2 },
          [4, 0] => { total: 49, last: 6 }
        }
      )
    end
  end
end
