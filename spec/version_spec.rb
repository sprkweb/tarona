RSpec.describe 'Version' do
  it 'has three parts divided by dot' do
    expect(Tarona::VERSION.split('.').size).to eq(3)
  end

  it 'consists of numbers' do
    Tarona::VERSION.split('.').each do |part|
      expect(part).to eq(part.to_i.to_s)
    end
  end

  it 'is frozen' do
    expect(Tarona::VERSION.frozen?).to be true
  end
end
