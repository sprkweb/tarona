RSpec.describe Tarona::Game::TickCounter do
  let(:session) { { act_inf: {} } }
  let(:subj) { described_class.new session }

  describe '#new' do
    it 'initializes its counter in the session' do
      subj
      expect(session[:act_inf][:tick]).to eq 1
    end

    it 'does not initializes its counter if it is' do
      session[:act_inf][:tick] = 5
      subj
      expect(session[:act_inf][:tick]).to eq 5
    end
  end

  describe '#tick' do
    it 'executes given block if it is given' do
      invoked = false
      listener = proc { invoked = true }
      subj.tick(&listener)
      expect(invoked).to be true
    end

    it 'increments counter' do
      session[:act_inf][:tick] = 3
      subj.tick
      expect(session[:act_inf][:tick]).to eq 4
    end

    it 'triggers the `:tick_start` event' do
      listener = double
      subj.on(:tick_start, &listener)
      session[:act_inf][:tick] = 2
      expect(listener).to receive(:call).with(3)
      subj.tick
    end

    it 'executes given block before the new tick' do
      session[:act_inf][:tick] = 7
      subj.tick do
        expect(session[:act_inf][:tick]).to eq(7)
      end
      expect(session[:act_inf][:tick]).to eq(8)
    end

    it 'triggers the event after the new tick is started' do
      session[:act_inf][:tick] = 1
      subj.on :tick_start do
        expect(session[:act_inf][:tick]).to eq 2
      end
      subj.tick
    end
  end

  describe '#whose' do
    entity_struct = Struct.new(:id)
    let(:entity) { entity_struct.new(:foo) }
    let(:entity2) { entity_struct.new(:bar) }
    let(:entity3) { entity_struct.new(:baz) }

    it 'always returns the candidate\'s id when it is only candidate' do
      subj.candidates << entity
      expect(subj.whose(123)).to eq(entity.id)
    end

    it 'sequentially chooses all candidates' do
      subj.candidate.merge! [entity, entity2, entity3]
      expect(subj.whose(1)).to eq(entity.id)
      expect(subj.whose(2)).to eq(entity2.id)
      expect(subj.whose(3)).to eq(entity3.id)
      expect(subj.whose(4)).to eq(entity.id)
    end
  end
end
