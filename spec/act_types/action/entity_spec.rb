RSpec.describe Tarona::Action::Entity do
  let(:subj) { described_class.new :wolf, :wolf_template }

  it 'has no events' do
    expect(described_class).not_to include(Tardvig::Events)
  end

  it 'includes identificator' do
    expect(subj.id).to be(:wolf)
  end

  it 'includes template' do
    expect(subj.template).to be(:wolf_template)
  end

  it 'can return its raw version' do
    expect(subj.raw).to eq(id: :wolf, svg_id: :wolf_template)
  end

  describe '#hexes' do
    it 'describes what places does the entity takes relatively to itself' do
      hexes = [[0, 0], [0, 1]]
      subj = described_class.new :wolf, :wolf_template, hexes: hexes
      expect(subj.hexes).to eq(hexes)
    end

    it 'returns [[0, 0]] by default' do
      expect(subj.hexes).to eq([[0, 0]])
    end
  end
end
