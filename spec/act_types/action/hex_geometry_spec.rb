describe Tarona::Action::HexGeometry do
  subject(:modul) { described_class }
  it 'can calculate width of a hex' do
    expect(modul.width(Math.sqrt(3))).to be_within(0.1).of(3)
    expect(modul.width(Math.sqrt(27))).to be_within(0.1).of(9)
  end

  it 'can calculate height of a hex' do
    expect(modul.height(1)).to eq(2)
    expect(modul.height(1.5)).to eq(3)
  end

  it 'can calculate how much vertical space does a hex take in a pattern' do
    expect(modul.vertical_space(4)).to eq(6)
    expect(modul.vertical_space(6)).to eq(9)
  end

  it 'can create a SVG line of a hex' do
    expect(modul.get_line([0, 0], 10)).to eq('M 8.6602540378 5.0 L 0.0 10.0 L -8.6602540378 5.0 L -8.6602540378 -5.0 L 0.0 -10.0 L 8.6602540378 -5.0 Z')
    expect(modul.get_line([10, 15], 20)).to eq('M 27.3205080757 25.0 L 10.0 35.0 L -7.3205080757 25.0 L -7.3205080757 5.0 L 10.0 -5.0 L 27.3205080757 5.0 Z')
  end
end
