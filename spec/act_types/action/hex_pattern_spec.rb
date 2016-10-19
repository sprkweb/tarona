describe Tarona::Action::HexPattern do
  subject(:modul) { described_class }

  let :first do
    {
      hex_size: 15, rows: 10, cols: 10, hex_crds: [3, 4],
      width: 273, height: 233, pos: [90.9326673974, 105]
    }
  end
  let :sec do
    {
      hex_size: 20, rows: 5, cols: 5, hex_crds: [2, 0],
      width: 191, height: 160, pos: [86.6025403784, 20]
    }
  end

  it 'can calculate width of your hexagonal pattern' do
    expect(modul.width(first[:cols], first[:hex_size])).to eq(first[:width])
    expect(modul.width(sec[:cols], sec[:hex_size])).to eq(sec[:width])
  end

  it 'can calculate height of your hexagonal pattern' do
    expect(modul.height(first[:rows], first[:hex_size])).to eq(first[:height])
    expect(modul.height(sec[:rows], sec[:hex_size])).to eq(sec[:height])
  end

  it 'can calculate position of your hexagonal pattern' do
    expect(modul.get_pos(first[:hex_crds], first[:hex_size])).to eq(first[:pos])
    expect(modul.get_pos(sec[:hex_crds], sec[:hex_size])).to eq(sec[:pos])
  end
end
