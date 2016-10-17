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
    expect(modul.get_line([0, 0], 10)).to eq('M 8.6602540378 5 L 0 10 L -8.6602540378 5 L -8.6602540378 -5 L 0 -10 L 8.6602540378 -5 Z')
    expect(modul.get_line([10, 15], 20)).to eq('M 27.3205080757 25 L 10 35 L -7.3205080757 25 L -7.3205080757 5 L 10 -5 L 27.3205080757 5 Z')
  end
end
