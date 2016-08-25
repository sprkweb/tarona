RSpec.describe Tarona::WebServer do
  it 'is Rack application' do
    expect(described_class.respond_to?(:call)).to be true
  end

  it 'is Sinatra application' do
    expect(described_class.ancestors).to include(Sinatra::Base)
  end

  let(:toolkit) { double }

  it 'supports toolkit' do
    old_value = described_class.tk
    described_class.tk = toolkit
    expect(described_class.tk).to be toolkit
    described_class.tk = old_value
  end
end