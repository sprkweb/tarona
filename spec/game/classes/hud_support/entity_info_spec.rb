RSpec.describe Tarona::Game::HudSupport::EntityInfo do
  let(:listener) { proc {} }
  let(:entity_place) { [3, 2] }
  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:entities_index) { { foo: entity_place } }
  let(:io) { Object.new.extend Tardvig::Events }
  let(:act) { double 'act' }
  let :session do
    { act_inf: { landscape: map, entities_index: entities_index } }
  end
  let(:entity) { double 'entity' }
  let(:attrs) { { hp: 2, max_hp: 3, energy: 5, max_energy: 7, name: 'foo' } }

  before :each do
    allow(act).to receive(:on).with(:end)
    allow(act).to receive(:io).and_return(io)
    allow(entity).to receive(:id).and_return(:foo)
    map.get(*entity_place)[:e] = [entity]
    described_class.call act: act, session: session
  end

  it 'is extension for acts' do
    expect(described_class.ancestors.include?(Tarona::PrManager)).to be true
  end

  it 'sends attributes of requested entity' do
    attrs.each do |name, value|
      expect(entity).to receive(name).and_return(value)
    end
    io.on :entity_info_show, &listener
    expect(listener).to receive(:call).with(attrs)
    io.happen :entity_info_request, id: entity.id
  end

  it 'sends only certain attributes' do
    attrs = { hp: 2, max_energy: 7, can_dance: true }
    attrs.each do |name, value|
      allow(entity).to receive(name).and_return(value)
    end
    io.on :entity_info_show, &listener
    expect(listener).to receive(:call).with(hp: 2, max_energy: 7)
    io.happen :entity_info_request, id: entity.id
  end

  it 'does nothing if there is no such entity' do
    attrs.each do |name, value|
      allow(entity).to receive(name).and_return(value)
    end
    io.on :entity_info_show, &listener
    expect(listener).not_to receive(:call).with(attrs)
    io.happen :entity_info_request, id: :bar
  end

  it 'does nothing if the entity is not on the map' do
    attrs.each do |name, value|
      allow(entity).to receive(name).and_return(value)
    end
    io.on :entity_info_show, &listener
    expect(listener).not_to receive(:call).with(attrs)
    map.get(*entity_place).delete :e
    io.happen :entity_info_request, id: :foo
  end

  it 'does nothing if the entity has no such attributes' do
    allow(entity).to receive(:can_dance).and_return(true)
    io.on :entity_info_show, &listener
    expect(listener).not_to receive(:call).with(attrs)
    io.happen :entity_info_request, id: :foo
  end
end
