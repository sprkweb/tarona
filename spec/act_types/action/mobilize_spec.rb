RSpec.describe Tarona::Action::Mobilize do
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:io) { Object.new.extend Tardvig::Events }
  let(:entities_index) { {} }
  let(:path_obj) { double }
  let(:catalyst) { double }
  let :entity do
    Tarona::Action::WorkableEntity.new(
      :me, :man,
      tags: [:movable, :user_controlled], max_energy: 100
    )
  end
  let(:from) { [3, 5] }
  let(:to) { [5, 6] }
  let(:path) { { found: true, costs: { to => { total: 87 } } } }
  FakeAction = Struct.new :io do
    include Tardvig::Events
  end
  let(:act) { FakeAction.new(io) }

  before :each do
    map.get(*from)[:e] = [entity]
    entities_index[entity.id] = from
    allow(Tarona::Action::Pathfinder::FindPath).to receive(:call) { path_obj }
    allow(Tarona::Action::PlaceEntity).to receive(:move)
    allow(path_obj).to receive(:result) { path }
    allow(act).to receive(:io) { io }
    described_class.call act: act, map: map, entities_index: entities_index
    allow(io).to receive(:happen).and_call_original
  end

  it 'is command' do
    expect(described_class.superclass).to be(Tardvig::Command)
  end

  it 'moves entities on request' do
    expect(Tarona::Action::PlaceEntity).to receive(:move)
      .with(map, entity, from, to)
    io.happen :move_request, entity_id: entity.id, to: to
    expect(entities_index[entity.id]).to eq(to)
  end

  it 'uses pathfinder' do
    expect(Tarona::Action::Pathfinder::FindPath).to receive(:call) { path_obj }
    expect(path_obj).to receive(:result) { path }
    io.happen :move_request, entity_id: entity.id, to: to
  end

  it 'sends message back if request is accepted' do
    expect(io).to receive(:happen).with(:move, entity_id: entity.id, to: to)
    io.happen :move_request, entity_id: entity.id, to: to
  end

  it 'does not work after act is ended' do
    act.happen :end
    expect(Tarona::Action::PlaceEntity).not_to receive(:move)
    expect(io).not_to receive(:happen).with(:move, entity_id: entity.id, to: to)
    io.happen :move_request, entity_id: entity.id, to: to
  end

  describe 'does not move entity which' do
    before :each do
      allow(io).to receive(:happen) do |ev|
        raise 'Event is not allowed' if ev == :move
      end
    end

    it 'is not controlled by user' do
      entity.tags.delete :user_controlled
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
      expect(entities_index[entity.id]).to eq(from)
    end

    it 'is not movable entities' do
      entity.tags.delete :movable
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
      expect(entities_index[entity.id]).to eq(from)
    end

    it 'is not in index' do
      entities_index.delete entity.id
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
    end

    it 'is not on map' do
      map.get(*from)[:e].delete entity
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
      expect(entities_index[entity.id]).to eq(from)
    end

    it 'can not go this way' do
      path[:found] = false
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
      expect(entities_index[entity.id]).to eq(from)
    end

    it 'does not have enough energy' do
      path[:costs][to][:total] = 121
      expect(Tarona::Action::PlaceEntity).not_to receive(:move)
      io.happen :move_request, entity_id: entity.id, to: to
      expect(entities_index[entity.id]).to eq(from)
    end
  end
end
