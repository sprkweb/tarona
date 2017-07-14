RSpec.describe Tarona::Game::HudSupport::MovementPotential do
  let(:listener) { proc {} }
  let(:entity_place) { [3, 2] }
  let(:map) { double 'map' }
  let(:entities_index) { { foo: entity_place } }
  let(:io) { Object.new.extend Tardvig::Events }
  let(:rules) { double 'rules' }
  let(:mobilize) { double 'mobilize' }
  let(:catalyst) { double 'catalyst' }
  let(:act) { double 'act' }
  let :session do
    { act_inf: { landscape: map, entities_index: entities_index } }
  end
  let(:entity) { double 'entity' }
  let :reachable do
    {
      places: { [2, 1] => nil, [3, 2] => [2, 1] },
      costs: { [2, 1] => 1, [3, 2] => 2 }
    }
  end

  before :each do
    allow(act).to receive(:on).with(:end)
    allow(act).to receive(:io).and_return(io)
    allow(act).to receive(:rules).and_return(rules)
    allow(rules).to receive(:mobilize).and_return(mobilize)
    allow(mobilize).to receive(:catalyst).and_return(catalyst)
    allow(entity).to receive(:id).and_return(:foo)
    allow(entity).to receive(:energy).and_return(123)
    allow(entity).to receive(:tags).and_return([:movable, :user_controlled])
    allow(Tarona::Action::Pathfinder::FindReachable).to receive(:call)
      .with(
        map: map, from: entity_place, entity: entity, max_cost: entity.energy,
        catalyst: catalyst
      )
      .and_return(Struct.new(:result).new(reachable))
    allow(Tarona::Action::PlaceEntity).to receive(:find)
      .with(map, entities_index, entity.id).and_return(entity)
    allow(io).to receive(:happen).and_call_original
    described_class.call act: act, session: session
  end

  it 'is extension for acts' do
    expect(described_class.ancestors.include?(Tarona::PrManager)).to be true
  end

  it 'sends back reachable places for given entity' do
    expect(io).to receive(:happen).with(
      :movement_potential_show,
      entity_id: entity.id,
      from: entity_place,
      reachable: {
        places: [[[2, 1], nil], [[3, 2], [2, 1]]],
        costs: [[[2, 1], 1], [[3, 2], 2]]
      }
    )
    io.listeners(:movement_potential_request).clone.each do |listener|
      listener.call entity_id: entity.id
    end
  end

  it 'does nothing when there is no such entity' do
    expect(Tarona::Action::PlaceEntity).to receive(:find)
      .with(map, entities_index, entity.id).and_return(nil)
    expect(io).not_to receive(:happen).with(:movement_potential_show, anything)
    io.happen :movement_potential_request, entity_id: entity.id
  end

  it 'does nothing when the entity is not movable' do
    entity.tags.delete :movable
    expect(io).not_to receive(:happen).with(:movement_potential_show, anything)
    io.happen :movement_potential_request, entity_id: entity.id
  end

  it 'does nothing when the entity is not under control' do
    entity.tags.delete :user_controlled
    expect(io).not_to receive(:happen).with(:movement_potential_show, anything)
    io.happen :movement_potential_request, entity_id: entity.id
  end
end
