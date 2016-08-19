RSpec.describe Tarona::WebServer do
  it 'is Rack application' do
    expect(described_class.respond_to?(:call)).to be true
  end

  it 'is Sinatra application' do
    expect(described_class.ancestors).to include(Sinatra::Base)
  end
end