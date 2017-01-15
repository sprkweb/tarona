RSpec.describe PriorityQueue do
  let(:subj) { described_class.new }

  it 'can return its size' do
    expect(subj.size).to eq(0)
    subj[1] = Object.new
    expect(subj.size).to eq(1)
    subj[55] = Object.new
    subj[7] = Object.new
    expect(subj.size).to eq(3)
  end

  it 'can say whether it is empty' do
    expect(subj.empty?).to be true
    subj[1] = Object.new
    expect(subj.empty?).to be false
    subj.pop
    expect(subj.empty?).to be true
  end

  it 'raises an exception when priority < 0' do
    expect { subj[-5] = :foo }.to raise_error(ArgumentError)
  end

  describe '#pop' do
    it 'returns element with the smallest priority' do
      subj[999] = '!'
      subj[5] = 'e'
      subj[11] = 'l'
      subj[0] = 'h'
      subj[110.0] = 'o'
      sum = ''
      5.times { sum += subj.pop }
      expect(sum).to eq('helo!')
    end

    it 'returns nil if there are no elements' do
      expect(subj.pop).to be nil
      subj[999] = :foo
      expect(subj.pop).to be :foo
      expect(subj.pop).to be nil
    end
  end
end
