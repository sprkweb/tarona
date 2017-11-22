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
      session[:act_inf][:tick] = 2
      expect(subj).to receive(:happen).with(:tick_start, num: 3)
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
    entity_struct = Struct.new(:id, :speed)
    let(:entity) { entity_struct.new(:entity, 2) }
    let(:entity2) { entity_struct.new(:entity2, 0) }
    let(:entity3) { Struct.new(:id).new(:entity3) }

    before :each do
      session[:act_inf][:entities_index] = {}
      [:entity, :entity2, :entity3].each do |e|
        session[:act_inf][:entities_index][e] = send e
      end
      subj.candidates.concat [entity, entity2, entity3]
    end

    it 'sequentially chooses all candidates' do
      expect(subj.whose(1)).to eq(entity.id)
      expect(subj.whose(2)).to eq(entity.id)
      session[:act_inf][:tick] = 3
      expect(subj.whose(3)).to eq(entity3.id)
      session[:act_inf][:tick] = 4
      expect(subj.whose(4)).to eq(entity.id)
    end

    it 'does not chooses candidates which are not in index' do
      session[:act_inf][:entities_index].delete :entity
      expect(subj.whose(1)).to eq(entity3.id)
      session[:act_inf][:tick] = 2
      expect(subj.whose(2)).to eq(entity3.id)
      session[:act_inf][:tick] = 3
      expect(subj.whose(3)).to eq(entity3.id)
    end

    it 'returns the candidate for current tick if no argument given' do
      expect(subj.whose).to eq(entity.id)
      session[:act_inf][:tick] = 2
      expect(subj.whose).to eq(entity.id)
      session[:act_inf][:tick] = 3
      expect(subj.whose).to eq(entity3.id)
      session[:act_inf][:tick] = 4
      expect(subj.whose).to eq(entity.id)
    end

    it 'raises exception if no candidates available' do
      subj.candidates.delete entity3
      session[:act_inf][:entities_index].delete :entity
      expect { subj.whose }.to raise_error('No candidates')
    end

    it 'raises exception if you request moment from far future' do
      expect { subj.whose(4) }.to raise_error('Invalid history')
      expect { subj.whose(123) }.to raise_error('Invalid history')
    end
  end
end
