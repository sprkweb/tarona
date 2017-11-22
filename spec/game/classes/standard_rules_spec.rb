RSpec.describe Tarona::Game::StandardRules do
  let :landscape do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:entities_index) { {} }
  let(:catalyst_inst) { double 'catalyst_inst' }
  let :session do
    {
      act_inf: {
        landscape: landscape,
        entities_index: entities_index,
        catalyst: catalyst_inst
      }
    }
  end

  let(:io) { double 'io' }
  let(:act) { double 'act' }
  let(:subj) { described_class.call act: act, session: session }

  let(:place) { [4, 0] }
  entity_class = Struct.new(:id, :tags, :ai)
  let(:just_entity) { entity_class.new(:just_entity, [], nil) }
  let(:ai_entity) { entity_class.new(:ai_entity, [], double('ai')) }
  let(:ai_entity2) { entity_class.new(:ai_entity2, [], double('ai2')) }
  let(:user_entity) { entity_class.new(:user_entity, [:user_controlled], nil) }
  empty_command = Class.new(Tardvig::Command) do
    include Tardvig::Events
    def process; end
  end
  before :each do
    landscape.get(*place)[:e] = [
      just_entity, ai_entity, ai_entity2, user_entity
    ]
    entities_index.merge!(
      user_entity: place, just_entity: place, ai_entity: place,
      ai_entity2: place
    )
    allow(act).to receive(:io).and_return(io)
    allow(Tarona::Action::Mobilize).to receive(:call) do |*args|
      empty_command.call(*args)
    end
    allow(Tarona::Game::InteractionsJudge).to receive(:call) do |*args|
      empty_command.call(*args)
    end
    allow(Tarona::Game::Death).to receive(:call)
    allow(Tarona::Game::RegenEnergy).to receive(:call)
    allow(Tarona::Game::SkipTick).to receive(:call)
  end

  describe '#tick_counter' do
    it 'is initialized' do
      expect(subj.tick_counter.class.ancestors).to(
        include(Tarona::Game::TickCounter)
      )
      expect(session[:act_inf][:tick]).to eq(1)
    end

    it 'gets only active entities as candidates' do
      expect(subj.tick_counter.candidates).to(
        eq [user_entity, ai_entity, ai_entity2]
      )
    end

    it 'runs AI of entity when its tick is started' do
      expect(ai_entity.ai).to receive(:call).with(act, ai_entity, session) do
        expect(session[:act_inf][:tick]).to eq(2)
      end
      expect(ai_entity2.ai).to receive(:call).with(act, ai_entity2, session) do
        expect(session[:act_inf][:tick]).to eq(3)
      end
      subj.tick_counter.tick
      expect(session[:act_inf][:tick]).to eq(4)
    end

    it 'does not run AI of entity without AI' do
      expect(subj.tick_counter).to receive(:whose).and_return(:user_entity)
      subj.tick_counter.tick
      expect(session[:act_inf][:tick]).to eq(2)
    end

    it 'runs AI for first tick too if it is available' do
      entities_index.replace ai_entity: place, user_entity: place
      expect(ai_entity.ai).to receive(:call).with(act, ai_entity, session) do
        expect(session[:act_inf][:tick]).to eq(1)
      end
      subj
      expect(session[:act_inf][:tick]).to eq(2)
    end

    it 'skips tick when entity is unavailable' do
      expect(subj.tick_counter).to receive(:whose).twice do
        if session[:act_inf][:tick] == 2
          :Kennedy
        else
          :just_entity
        end
      end
      subj.tick_counter.tick
      expect(session[:act_inf][:tick]).to eq(3)
    end
  end

  describe '#mobilize' do
    it 'is initialized' do
      subj
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
      expect(catalyst_inst).to receive(:call)
        .with(user_entity, [4, 2]).and_return(true)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be true
    end

    it 'does not move entity when it is not its tick' do
      subj.tick_counter.candidates << just_entity
      expect(subj.tick_counter).to receive(:whose).and_return(:just_entity)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be false
    end

    it 'does not move entity when catalyst returns false' do
      expect(catalyst_inst).to receive(:call)
        .with(user_entity, [4, 2]).and_return(false)
      expect(subj.mobilize.catalyst.call(user_entity, [4, 2])).to be false
    end
  end

  describe '#interactions_judge' do
    it 'is initialized' do
      subj
      expect(Tarona::Game::InteractionsJudge).to have_received(:call)
      expect(subj.interactions_judge.act).to be(act)
      expect(subj.interactions_judge.session).to be(session)
    end

    it 'starts a new tick after interaction' do
      expect(subj.tick_counter).to receive(:tick)
      subj.interactions_judge.happen :after_interact
    end

    it 'applies interaction when there is initiator\'s tick' do
      subj.tick_counter.candidates.replace [just_entity, ai_entity, ai_entity2]
      expect(subj.tick_counter).to receive(:whose).and_return(:just_entity)
      check = subj.interactions_judge.context_acceptable
      expect(check.call(just_entity, ai_entity, [3, 2])).to be true
    end

    it 'does not apply interaction when it is not its tick' do
      subj.tick_counter.candidates.replace [user_entity, ai_entity, just_entity]
      check = subj.interactions_judge.context_acceptable
      expect(check.call(just_entity, ai_entity, [3, 2])).to be false
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
