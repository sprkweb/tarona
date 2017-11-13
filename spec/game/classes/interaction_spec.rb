RSpec.describe Tarona::Game::Interaction do
  let(:owner) { double 'owner' }
  let(:name) { 'names/dance_battle' }
  let(:distance) { 3 }
  let(:io) { double 'io' }
  let :session do
    { tk: double('tk'), act_inf: { entities_index: { owner: [5, 5] } } }
  end
  let :subj do
    described_class.new owner: owner, name: name, distance: distance
  end

  let(:target) { double 'target' }
  before :each do
    allow(target).to receive(:id).and_return(:target)
    allow(target).to receive(:hexes)
      .and_return(even_row: [[0, 0], [1, 0]], odd_row: [[0, 0], [1, 0]])
    allow(owner).to receive(:id).and_return(:owner)
    allow(owner).to receive(:hexes)
      .and_return(even_row: [[0, 0]], odd_row: [[0, 0]])
  end

  describe '#new' do
    it 'initializes object\'s `owner` attribute' do
      expect(subj.owner).to be owner
    end

    it 'initializes object\'s `name` attribute' do
      expect(subj.name).to be name
    end

    it 'initializes object\'s `distance` attribute' do
      expect(subj.distance).to be distance
    end

    it 'sets distance to 0 by default' do
      subj = described_class.new
      expect(subj.distance).to be 0
    end
  end

  describe '#applicable?' do
    it 'is true when maximal distance is 0' do
      session[:act_inf][:entities_index][:target] = [999, 999]
      subj = described_class.new owner: owner, name: name, distance: 0
      expect(subj.applicable?(session, target)).to be true
    end

    it 'is true when target is closer than maximal distance' do
      session[:act_inf][:entities_index][:target] = [4, 3]
      expect(subj.applicable?(session, target)).to be true
    end

    it 'is false when target is too far' do
      session[:act_inf][:entities_index][:target] = [3, 1]
      expect(subj.applicable?(session, target)).to be false
    end

    it 'is true when target is at maximal distance' do
      session[:act_inf][:entities_index][:target] = [4, 2]
      expect(subj.applicable?(session, target)).to be true
    end

    it 'is true when part of target is at maximal distance' do
      session[:act_inf][:entities_index][:target] = [3, 2]
      expect(subj.applicable?(session, target)).to be true
    end
  end

  describe '#apply' do
    it 'is abstract' do
      expect do
        subj.apply(session, target, io)
      end.to raise_error(NotImplementedError)
    end
  end

  describe '#raw' do
    it 'presents object through common standard types' do
      expect(subj.raw).to eq name: name, distance: distance
    end
  end
end
