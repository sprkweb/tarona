RSpec.describe Tarona::Game::AI::Standard do
  entity_class = Struct.new(:id, :side, :tags, :hexes) do
    def move_cost(*_args)
      1
    end

    def interactions
      raise NotImplementedError
    end
  end
  let :me do
    entity_class.new(
      :me, :my_side, [:movable],
      even_row: [[0, 0], [0, -1], [1, -2]], odd_row: [[0, 0], [1, -1], [1, -2]]
    )
  end
  let :friend do
    entity_class.new(
      :friend, :my_side, [],
      even_row: [[0, 0]], odd_row: [[0, 0]]
    )
  end
  let :enemy do
    entity_class.new(
      :enemy, :other_side, [],
      even_row: [[0, 0], [-1, 0]], odd_row: [[0, 0], [-1, 0]]
    )
  end
  let :enemy2 do
    entity_class.new(
      :enemy2, :other_side, [],
      even_row: [[0, 0]], odd_row: [[0, 0]]
    )
  end

  let :landscape do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:index) { { me: [3, 4], friend: [4, 4], enemy: [6, 0], enemy2: [0, 4] } }
  let(:catalyst) { double 'catalyst' }
  let :session do
    {
      act_inf: {
        landscape: landscape, entities_index: index, catalyst: catalyst
      }
    }
  end

  let(:io) { Object.new.extend(Tardvig::Events) }
  let(:act) { Struct.new(:io).new(io) }

  let(:subj) { described_class }

  before :each do
    index.each do |name, place|
      Tarona::Action::PlaceEntity.add(landscape, send(name), place)
    end
  end

  describe '#find_nearest_entity' do
    it 'finds nearest entity when it is without block' do
      result = subj.find_nearest_entity(me, session)
      expect(result).to eq(friend)
    end

    it 'finds nearest entity which complies your conditions' do
      result = subj.find_nearest_entity(me, session) { |x| x.side != me.side }
      expect(result).to eq(enemy)
    end

    it 'returns nil when nothing is found' do
      result = subj.find_nearest_entity(me, session) { false }
      expect(result).to eq(nil)
    end
  end

  describe '#best_attack' do
    let :interactions do
      { bar: double('bar'), foo: double('foo'), foobar: double('foobar') }
    end

    before :each do
      allow(subj).to receive(:attacks_priority)
        .and_return([:foo, :bar, :baz])
      allow(me).to receive(:interactions).and_return(interactions)
    end

    it 'finds best attack' do
      expect(subj.best_attack(me, session)).to be :foo
    end

    it 'returns nil if it is not found' do
      allow(me).to receive(:interactions)
        .and_return(foobar: double, barbaz: double)
      expect(subj.best_attack(me, session)).to be nil
    end

    it 'choses only available attacks when enemy is given' do
      expect(interactions[:foo]).to receive(:applicable?)
        .with(session, enemy).and_return(false)
      expect(interactions[:bar]).to receive(:applicable?)
        .with(session, enemy).and_return(true)
      expect(subj.best_attack(me, session, enemy)).to be :bar
    end

    it 'returns nil if there are no available attacks' do
      expect(interactions[:foo]).to receive(:applicable?)
        .with(session, enemy).and_return(false)
      expect(interactions[:bar]).to receive(:applicable?)
        .with(session, enemy).and_return(false)
      expect(subj.best_attack(me, session, enemy)).to be nil
    end
  end

  describe '#move_to' do
    let :path_inf do
      Struct
        .new(:result)
        .new(found: true, path: [[3, 4], [4, 4], [4, 5], [4, 6]])
    end

    context 'empty final place' do
      before :each do
        allow(Tarona::Action::Pathfinder::FindPath).to receive(:call)
          .with(
            hash_including(
              map: landscape, catalyst: catalyst, entity: me, from: [3, 4]
            )
          ).and_return(path_inf)
      end

      it 'moves entity to the final point' do
        expect(Tarona::Action::Pathfinder::FindPath).to receive(:call)
          .with(
            map: landscape, catalyst: catalyst, entity: me,
            from: [3, 4], to: [4, 6]
          ).and_return(path_inf)
        subj.move_to act, me, session, [4, 6]
        expect(index[me.id]).to eq [4, 6]
        expect(Tarona::Action::PlaceEntity.find(landscape, index, me.id))
          .to eq me
      end

      it 'returns information about path' do
        inf = subj.move_to act, me, session, [4, 6]
        expect(inf).to eq path_inf: path_inf.result, final: [4, 6]
      end

      it 'sends :move event on io' do
        listener = proc {}
        act.io.on(:move, &listener)
        expect(listener).to receive(:call).with(entity_id: :me, to: [4, 6])
        subj.move_to act, me, session, [4, 6]
      end

      it 'does not move entity without :movable tag' do
        me.tags.delete :movable
        inf = subj.move_to act, me, session, [4, 6]
        expect(inf).to be false
        expect(index[me.id]).to eq([3, 4])
        expect(Tarona::Action::PlaceEntity.find(landscape, index, me.id))
          .to eq me
        expect(io).not_to receive(:happen).with(:move, anything)
      end

      it 'does not move entity when path is not found' do
        expect(Tarona::Action::Pathfinder::FindPath).to receive(:call)
          .and_return(Struct.new(:result).new(found: false))
        inf = subj.move_to act, me, session, [4, 6]
        expect(inf).to be false
        expect(index[me.id]).to eq([3, 4])
        expect(Tarona::Action::PlaceEntity.find(landscape, index, me.id))
          .to eq me
        expect(io).not_to receive(:happen).with(:move, anything)
      end

      it 'calls given block for each point of the path' do
        path = path_inf.result[:path].clone
        subj.move_to act, me, session, [4, 6] do |*args|
          place = path.shift
          expect(args[0]).to eq(place)
          expect(args[1]).to eq(path[0])
          expect(args[2]).to eq(path_inf.result)
          true
        end
        expect(path).to eq []
      end

      it 'stops movement when block returns false' do
        subj.move_to act, me, session, [4, 6] do |cur_place|
          cur_place != [4, 4]
        end
        expect(index[me.id]).to eq([4, 4])
        expect(Tarona::Action::PlaceEntity.find(landscape, index, me.id))
          .to eq me
      end

      it 'returns real final point, not planned' do
        listener = proc {}
        act.io.on(:move, &listener)
        expect(listener).to receive(:call).with(hash_including(to: [4, 4]))
        result = subj.move_to act, me, session, [4, 6] do |cur_place|
          cur_place != [4, 4]
        end
        expect(result[:final]).to eq([4, 4])
      end
    end
  end
end
