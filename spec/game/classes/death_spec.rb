RSpec.describe Tarona::Game::Death do
  mortal_entity_class = Struct.new(:id, :tags, :hp)
  immortal_entity_class = Struct.new(:id, :tags)
  let(:foo_place) { [7, 1] }
  let(:bar_place) { [2, 9] }
  let(:foo) { mortal_entity_class.new :foo, [:mortal], 1 }
  let(:bar) { immortal_entity_class.new :bar, [] }

  let :landscape do
    Tarona::Action::Landscape.new(Array.new(10) { Array.new(10) { {} } })
  end
  let(:index) { { foo: foo_place, bar: bar_place } }
  let(:tick_counter) { Object.new.extend Tardvig::Events }
  let(:io) { Object.new.extend(Tardvig::Events) }

  let :subj do
    described_class.new(
      landscape: landscape,
      entities_index: index,
      tick_counter: tick_counter,
      io: io
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

  it 'kills entities with HP = 0 after new tick' do
    foo.hp = 0
    subj.call
    expect(Tarona::Action::PlaceEntity).to receive(:remove)
      .with(landscape, foo, foo_place)
    tick_counter.happen :tick_start
    expect(index.keys).to eq [:bar]
  end

  it 'sends message to remove entity via IO' do
    foo.hp = 0
    subj.call
    expect(Tarona::Action::PlaceEntity).to receive(:remove)
      .with(landscape, foo, foo_place)
    expect(io).to receive(:happen).with(:remove, entity_id: :foo)
    tick_counter.happen :tick_start
  end

  it 'kills entities with HP below 0' do
    bar.define_singleton_method(:hp) { -5 }
    bar.tags << :mortal
    subj.call
    expect(Tarona::Action::PlaceEntity).to receive(:remove)
      .with(landscape, bar, bar_place)
    tick_counter.happen :tick_start
    expect(index.keys).to eq [:foo]
  end

  it 'does not kill mortal entities without HP' do
    bar.tags << :mortal
    subj.call
    expect(Tarona::Action::PlaceEntity).not_to receive(:remove)
    tick_counter.happen :tick_start
    expect(index.keys).to eq [:foo, :bar]
  end

  it 'does not send message to remove entity when it is alive' do
    bar.tags << :mortal
    subj.call
    expect(io).not_to receive(:happen).with(:remove, anything)
    tick_counter.happen :tick_start
  end

  it 'does not kill immortal entities with 0 HP' do
    foo.hp = 0
    foo.tags.delete :mortal
    subj.call
    expect(Tarona::Action::PlaceEntity).not_to receive(:remove)
    tick_counter.happen :tick_start
  end

  it 'does not kill mortal entities with some HP' do
    subj.call
    expect(Tarona::Action::PlaceEntity).not_to receive(:remove)
    tick_counter.happen :tick_start
  end
end
