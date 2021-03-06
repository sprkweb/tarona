RSpec.describe Tarona::Game::InteractionsJudge do
  act_class = Struct.new :io do
    include Tardvig::Events
  end
  target_class = Struct.new :id
  owner_class = Struct.new :id, :tags, :interactions

  let(:owner_place) { [3, 2] }
  let(:target_place) { [2, 5] }

  let :map do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:entities_index) { { me: owner_place, enemy: target_place } }
  let(:io) { Object.new.extend Tardvig::Events }
  let(:act) { act_class.new io }
  let :session do
    { act_inf: { landscape: map, entities_index: entities_index } }
  end
  let(:subj) { described_class.new act: act, session: session }

  let(:interaction) { double 'interaction' }
  let(:target) { target_class.new :enemy }
  let :owner do
    owner_class.new :me, [:user_controlled], say_hi: interaction
  end

  let :event_args do
    { from_entity: :me, target: :enemy, interaction_id: :say_hi }
  end

  before :each do
    map.get(*owner_place)[:e] = [owner]
    map.get(*target_place)[:e] = [target]
    allow(interaction).to receive(:applicable?)
      .with(session, target).and_return(true)
    allow(interaction).to receive(:apply)
    subj.call
  end

  it 'is extension for acts' do
    expect(described_class.ancestors.include?(Tarona::PrManager)).to be true
  end

  it 'applies interaction when player requests that' do
    expect(interaction).to receive(:apply).with(session, target, io)
    io.happen :interaction_request, event_args
  end

  it 'does not apply interaction when entity is not owned by user' do
    expect(owner).to receive(:tags).and_return([])
    expect(interaction).not_to receive(:apply)
    io.happen :interaction_request, event_args
  end

  it 'does not apply interaction when it says it is not applicable' do
    expect(interaction).to receive(:applicable?)
      .with(session, target).and_return(false)
    expect(interaction).not_to receive(:apply)
    io.happen :interaction_request, event_args
  end

  it 'does nothing when there is no such interaction' do
    expect(owner).to receive(:interactions).and_return({})
    expect(interaction).not_to receive(:apply)
    io.happen :interaction_request, event_args
  end

  it 'does nothing when there is no such owner' do
    expect(interaction).not_to receive(:apply)
    entities_index.delete :me
    io.happen :interaction_request, event_args
  end

  it 'does nothing when there is no such target' do
    expect(interaction).not_to receive(:apply)
    entities_index.delete :enemy
    io.happen :interaction_request, event_args
  end

  it 'does nothing when owner has no interactions' do
    owner = Struct.new(:id, :tags).new :me, [:user_controlled]
    map.get(*owner_place)[:e] = [owner]
    expect(interaction).not_to receive(:apply)
    io.happen :interaction_request, event_args
  end

  it 'does nothing when interaction is not interaction' do
    interaction = double 'fake_interaction'
    expect(owner).to receive(:interactions).and_return say_hi: interaction
    expect(interaction).not_to receive(:apply)
    io.happen :interaction_request, event_args
  end

  it 'works as always when owner and target at the same place' do
    place = [3, 4]
    map.get(*place)[:e] = [target, owner]
    map.get(*owner_place)[:e] = []
    map.get(*target_place)[:e] = []
    entities_index.merge! me: place, enemy: place
    expect(interaction).to receive(:apply).with(session, target, io)
    io.happen :interaction_request, event_args
  end

  it 'works with any identificators of owner, target and interaction' do
    entities_index.merge! alice: owner_place, bob: target_place
    expect(owner).to receive(:id).and_return(:alice)
    expect(target).to receive(:id).and_return(:bob)
    expect(owner).to receive(:interactions).and_return look: interaction
    expect(interaction).to receive(:apply).with(session, target, io)
    io.happen(
      :interaction_request,
      from_entity: :alice, target: :bob, interaction_id: :look
    )
  end

  it 'triggers the `:after_interact` event' do
    expect(subj).to receive(:happen).with(
      :after_interact, from: owner, to: target, interaction: interaction
    ) do
      expect(interaction).to have_received(:apply)
    end
    io.happen :interaction_request, event_args
  end

  it 'does not trigger the `:after_interact` event without interact' do
    expect(interaction).to receive(:applicable?)
      .with(session, target).and_return(false)
    expect(subj).not_to receive(:happen).with(:after_interact, anything)
    io.happen :interaction_request, event_args
  end

  context 'with context_acceptable option' do
    let(:context_acceptable) { double }
    let :subj do
      described_class.new(
        act: act, session: session, context_acceptable: context_acceptable
      )
    end

    it 'does nothing when context is unacceptable' do
      expect(context_acceptable).to receive(:call)
        .with(owner, target, interaction).and_return(false)
      expect(interaction).not_to receive(:apply)
      io.happen :interaction_request, event_args
    end

    it 'applies interaction when context is acceptable' do
      expect(context_acceptable).to receive(:call).and_return(true)
      expect(interaction).to receive(:apply)
      io.happen :interaction_request, event_args
    end
  end
end
