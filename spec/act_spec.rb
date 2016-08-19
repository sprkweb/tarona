RSpec.describe Tarona::Act do
  let(:act) { described_class.new }

  it 'inherits the tardvig act' do
    expect(described_class.superclass).to be(Tardvig::Act)
  end

  it 'include events' do
    expect(act).to be_a_kind_of(Tardvig::Events)
  end
end