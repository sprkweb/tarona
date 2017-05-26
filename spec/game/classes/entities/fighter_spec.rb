RSpec.describe Tarona::Game::Fighter do
  it 'is type of entity' do
    ancestors = described_class.ancestors
    expect(ancestors.include?(Tarona::Action::Entity)).to be true
  end

  it 'is workable' do
    ancestors = described_class.ancestors
    expect(ancestors.include?(Tarona::Action::Workable)).to be true
  end

  it 'is movable' do
    ancestors = described_class.ancestors
    expect(ancestors.include?(Tarona::Action::Movable)).to be true
  end

  it 'has changeable HP attribute' do
    subj = described_class.new :fletcher, :his_template, {}
    subj.hp = 500
    expect(subj.hp).to eq 500
  end

  describe '#raw' do
    it 'also contains interactions' do
      interactions = { explode: double('interaction') }
      expect(interactions[:explode]).to receive(:raw).and_return(:airplane)
      subj = described_class.new(
        :bin_Laden, :skeleton, interactions: interactions
      )
      expect(subj.raw).to include interactions: { explode: :airplane }
    end
  end
end
