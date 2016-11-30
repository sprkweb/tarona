RSpec.describe Tarona::Action::Ground do
  let(:subj) { described_class.new :stone, :stone_template }

  it 'has no events' do
    expect(described_class).not_to include(Tardvig::Events)
  end

  it 'includes identificator' do
    expect(subj.id).to be(:stone)
  end

  it 'includes template' do
    expect(subj.template).to be(:stone_template)
  end

  it 'can return its raw version' do
    expect(subj.raw).to eq(id: :stone, svg_id: :stone_template)
  end
end
