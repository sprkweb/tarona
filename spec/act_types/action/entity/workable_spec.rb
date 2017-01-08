RSpec.describe Tarona::Action::WorkableEntity do
  it 'can be controlled by user' do
    entity = described_class.new :wolf, :wolf_template, user_controlled: true
    expect(entity.user_controlled).to be true
  end

  it 'can be not controlled by user' do
    entity = described_class.new :wolf, :wolf_template
    entity.user_controlled = false
    expect(entity.user_controlled).to be false
  end

  it 'has maximal amount of energy' do
    entity = described_class.new :wolf, :wolf_template, max_energy: 80
    expect(entity.max_energy).to eq(80)
  end

  it 'can change its maximal amount of energy' do
    entity = described_class.new :wolf, :wolf_template
    entity.max_energy = 100
    expect(entity.max_energy).to eq(100)
  end

  it 'has as much energy as it can by default' do
    entity = described_class.new :wolf, :wolf_template, max_energy: 80
    expect(entity.energy).to eq(80)
  end

  it 'does not change energy when its limit is changed' do
    entity = described_class.new :wolf, :wolf_template
    entity.max_energy = 100
    expect(entity.energy).to eq(100)
    entity.max_energy = 120
    expect(entity.energy).to eq(100)
    entity.max_energy = 80
    expect(entity.energy).to eq(100)
  end

  it 'can change energy' do
    entity = described_class.new :wolf, :wolf_template
    entity.energy = 100
    expect(entity.energy).to eq(100)
  end

  it 'can set default energy amount' do
    entity = described_class.new :wolf, :wolf_template, energy: 100
    expect(entity.energy).to eq(100)
  end

  describe '#tire' do
    it 'removes energy' do
      entity = described_class.new :wolf, :wolf_template, energy: 100
      expect(entity.tire(10)).to be true
      expect(entity.energy).to eq(90)
    end

    it 'removes all energy when no arguments given' do
      entity = described_class.new :wolf, :wolf_template, energy: 100
      expect(entity.tire).to be true
      expect(entity.energy).to eq(0)
    end

    it 'removes no energy when amount of energy is not enough' do
      entity = described_class.new :wolf, :wolf_template, energy: 80
      expect(entity.tire(100)).to be false
      expect(entity.energy).to eq(80)
    end
  end

  describe '#relax' do
    it 'restores energy' do
      entity = described_class.new(
        :wolf, :wolf_template, energy: 50, max_energy: 100
      )
      expect(entity.relax(10)).to eq(60)
      expect(entity.energy).to eq(60)
    end

    it 'restores all energy when no arguments given' do
      entity = described_class.new(
        :wolf, :wolf_template, energy: 50, max_energy: 100
      )
      expect(entity.relax).to eq(100)
      expect(entity.energy).to eq(100)
    end

    it 'can not overflow limit' do
      entity = described_class.new(
        :wolf, :wolf_template, energy: 50, max_energy: 100
      )
      expect(entity.relax(999)).to eq(100)
      expect(entity.energy).to eq(100)
    end
  end
end
