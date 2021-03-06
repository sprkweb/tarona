RSpec.describe Tarona::Game::Attack do
  let(:owner) { double 'owner' }
  let(:name) { 'names/dance_battle' }
  let(:distance) { 2 }
  let(:damage) { 34 }
  let(:visual_effect) { :moonwalk }
  let(:listener) { proc {} }
  let(:io) { Object.new.extend(Tardvig::Events) }
  let :session do
    { tk: double('tk'), act_inf: { entities_index: { owner: [5, 5] } } }
  end
  let :subj do
    described_class.new(
      owner: owner,
      name: name,
      distance: distance,
      damage: damage,
      visual_effect: visual_effect
    )
  end

  target_class = Struct.new :id, :hexes do
    attr_accessor :hp
  end
  let :target do
    target_class.new :target, even_row: [[0, 0]], odd_row: [[0, 0]]
  end
  before :each do
    target.hp = 100
    allow(owner).to receive(:id).and_return(:owner)
    allow(owner).to receive(:hexes)
      .and_return(even_row: [[0, 0]], odd_row: [[0, 0]])
  end

  it 'is interaction' do
    expect(described_class.superclass).to be(Tarona::Game::Interaction)
  end

  describe '#apply' do
    it 'reduces amount of enemy HP' do
      session[:act_inf][:entities_index][:target] = [5, 6]
      expect(subj.apply(session, target, io)).to be true
      expect(target.hp).to eq(66)
    end

    it 'returns true for entity without HP, but does nothing' do
      session[:act_inf][:entities_index][:wall] = [5, 6]
      wall = Struct.new(:id, :hexes).new(:wall, target.hexes)
      expect(subj.apply(session, wall, io)).to be true
    end

    it 'returns false when enemy is too far' do
      session[:act_inf][:entities_index][:target] = [5, 8]
      expect(subj.apply(session, target, io)).to be false
      expect(target.hp).to eq(100)
    end

    it 'returns true when enemy is within the distance' do
      session[:act_inf][:entities_index][:target] = [5, 7]
      target.hp = 50
      expect(subj.apply(session, target, io)).to be true
      expect(target.hp).to eq(16)
    end

    it 'returns true when distance is infinite' do
      session[:act_inf][:entities_index][:target] = [50, 67]
      subj = described_class.new(
        owner: owner, name: name, distance: 0, damage: -12
      )
      expect(subj.apply(session, target, io)).to be true
      expect(target.hp).to eq(112)
    end

    it 'shows visual effect if it is' do
      session[:act_inf][:entities_index][:target] = [5, 6]
      expect(Tarona::Game::ViewScripts).to(
        receive(:show_effect).with(io, :moonwalk, from: [5, 5], to: [5, 6])
      )
      subj.apply(session, target, io)
    end

    it 'does not show visual effect if interaction is not applied' do
      session[:act_inf][:entities_index][:target] = [5, 8]
      expect(Tarona::Game::ViewScripts).not_to receive(:show_effect)
      subj.apply(session, target, io)
    end
  end
end
