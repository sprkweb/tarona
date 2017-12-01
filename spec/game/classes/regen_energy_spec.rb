RSpec.describe Tarona::Game::RegenEnergy do
  entity = Struct.new(:id, :tags)
  entity_with_energy =
    Struct.new(:id, :tags, :energy, :max_energy, :regen_energy)
  let(:foo_place) { [7, 1] }
  let(:bar_place) { [2, 9] }
  let(:foo) { entity.new :foo, [] }
  let(:bar) { entity_with_energy.new :bar, [:regen_energy], 100, 150, 20 }

  let(:landscape) { double 'landscape' }
  let(:index) { double 'index' }

  tick_counter_class = Class.new do
    include Tardvig::Events

    def whose(tick)
      case tick
        when 4 then :foo
        when 5 then :bar
      end
    end
  end
  let(:tick_counter) { tick_counter_class.new }

  let :subj do
    described_class.new(
      landscape: landscape,
      entities_index: index,
      tick_counter: tick_counter
    )
  end

  before :each do
    allow(Tarona::Action::PlaceEntity).to receive(:find) do |_, _, id|
      case id
        when :foo then foo
        when :bar then bar
      end
    end
  end

  it 'regenerates energy after new tick' do
    subj.call
    expect(bar.energy).to eq 100
    tick_counter.happen :tick_end, num: 5
    expect(bar.energy).to eq 120
  end

  it 'respects max_energy' do
    subj.call
    bar.energy = 140
    tick_counter.happen :tick_end, num: 5
    expect(bar.energy).to eq 150
    tick_counter.happen :tick_end, num: 5
    expect(bar.energy).to eq 150
  end

  it 'does not regenerate energy without :regen_energy tag' do
    subj.call
    bar.tags.delete :regen_energy
    tick_counter.happen :tick_end, num: 5
    expect(bar.energy).to eq 100
  end

  it 'does not raise exception for entity without energy' do
    subj.call
    foo.tags << :regen_energy
    tick_counter.happen :tick_end, num: 4
  end
end
