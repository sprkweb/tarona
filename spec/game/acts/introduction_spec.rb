RSpec.describe Tarona::Introduction do
  it 'is text act' do
    expect(described_class.superclass).to be(Tarona::TextAct)
  end

  let(:tk) { double }
  let(:i18n) { double }
  let(:act) { described_class.new io: spy, tk: tk }
  before :example do
    allow(tk).to receive(:i18n) { i18n }
  end

  it 'gets text from the `i18n` tool' do
    expect(tk.i18n).to receive(:[]) { {} }
    act.call
  end
end