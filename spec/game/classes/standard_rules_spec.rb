RSpec.describe Tarona::Game::StandardRules do
  let :landscape do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:entities_index) { {} }
  let :session do
    { act_inf: { landscape: landscape, entities_index: entities_index } }
  end
  let(:io) { double 'io' }
  let(:act) { double 'act' }
  let(:subj) { described_class.call act: act, session: session }

  entity_class = Struct.new(:id, :tags, :ai)
  let(:just_entity) { entity_class.new(:just_entity, [], nil) }
  let(:ai_entity) { entity_class.new(:ai_entity, [], double('ai')) }
  let(:user_entity) { entity_class.new(:user_entity, [:user_controlled], nil) }

  let(:catalyst_inst) { double 'catalyst_inst' }
  empty_command = Class.new(Tardvig::Command) do
    include Tardvig::Events
    def process; end
  end
  before :each do
    place = [4, 0]
    landscape.get(*place)[:e] = [just_entity, ai_entity, user_entity]
    entities_index.merge!(
      just_entity: place, ai_entity: place, user_entity: place
    )
    allow(act).to receive(:io).and_return(io)
    allow(Tarona::Action::Catalyst).to receive(:new).and_return(catalyst_inst)
    allow(Tarona::Action::Mobilize).to receive(:call) do |*args|
      empty_command.call(*args)
    end
    allow(Tarona::Game::InteractionsJudge).to receive(:call) do |*args|
      empty_command.call(*args)
    end
    allow(Tarona::Game::Death).to receive(:call)
    allow(subj.tick_counter).to receive(:whose) do |num|
      case num
      when 11 then :just_entity
      when 12 then :ai_entity
      when 13 then :user_entity
      else raise 'Unexpected tick number'
      end
    end
  end

  describe '#tick_counter' do
    it 'is initialized' do
      expect(subj.tick_counter.class.ancestors).to(
        include(Tarona::Game::TickCounter)
      )
      expect(session[:act_inf][:tick]).to eq(1)
    end

    it 'gets only active entities as candidates' do
      expect(subj.tick_counter.candidates).to eq [ai_entity, user_entity]
    end

    it 'runs AI of entity when its tick is started' do
      session[:act_inf][:tick] = 11
      expect(subj.tick_counter).to receive(:whose)
        .with(12).and_return(:ai_entity)
      expect(ai_entity.ai).to receive(:call).with(ai_entity, session) do
        expect(session[:act_inf][:tick]).to eq(12)
      end
      subj.tick_counter.tick
      expect(session[:act_inf][:tick]).to eq(13)
    end

    it 'does not run AI of entity without AI' do
      session[:act_inf][:tick] = 10
      subj.tick_counter.tick
      expect(session[:act_inf][:tick]).to eq(11)
    end
  end

  describe '#mobilize' do
    it 'is initialized' do
      expect(Tarona::Action::Mobilize).to have_received(:call)
      expect(subj.mobilize.act).to be(act)
      expect(subj.mobilize.map).to be(landscape)
      expect(subj.mobilize.entities_index).to be(entities_index)
    end

    it 'starts a new tick after movement' do
      expect(subj.tick_counter).to receive(:tick)
      subj.mobilize.happen :after_move
    end

    it 'moves entity when there is its tick' do
      session[:act_inf][:tick] = 13
      expect(catalyst_inst).to receive(:call)
        .with(user_entity, [4, 2]).and_return(true)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be true
    end

    it 'does not move entity when it is not its tick' do
      session[:act_inf][:tick] = 12
      expect(catalyst_inst).to receive(:call)
        .with(user_entity, [4, 2]).and_return(true)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be false
    end

    it 'does not move entity when catalyst returns false' do
      session[:act_inf][:tick] = 13
      expect(catalyst_inst).to receive(:call)
        .with(user_entity, [4, 2]).and_return(false)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be false
    end
  end

  describe '#interactions_judge' do
    it 'is initialized' do
      expect(Tarona::Game::InteractionsJudge).to have_received(:call)
      expect(subj.interactions_judge.act).to be(act)
      expect(subj.interactions_judge.session).to be(session)
    end

    it 'starts a new tick after interaction' do
      expect(subj.tick_counter).to receive(:tick)
      subj.interactions_judge.happen :after_interact
    end

    it 'applies interaction when there is initiator\'s tick' do
      session[:act_inf][:tick] = 12
      check = subj.interactions_judge.context_acceptable
      expect(check.call(ai_entity, user_entity, [3, 2])).to be true
    end

    it 'does not apply interaction when it is not its tick' do
      session[:act_inf][:tick] = 12
      check = subj.interactions_judge.context_acceptable
      expect(check.call(just_entity, user_entity, [3, 2])).to be false
    end
  end

  it 'calls death' do
    expect(Tarona::Game::Death).to have_received(:call).with(
      io: io,
      landscape: landscape,
      entities_index: entities_index,
      tick_counter: subj.tick_counter
    )
  end
end
