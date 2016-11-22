RSpec.describe Tarona::Act do
  let(:io) { Object.new.extend Tardvig::Events }
  let(:act) { described_class.new io: io }

  it 'inherits the tardvig act' do
    expect(described_class.superclass).to be(Tardvig::Act)
  end

  it 'include events' do
    expect(act).to be_a_kind_of(Tardvig::Events)
  end

  it 'send its displayed data when it is started' do
    expect(io).to receive(:happen).with(:act_start, kind_of(Hash))
    act.call
  end

  it 'send its displayed data when io is updated' do
    act.call
    expect(io).to receive(:happen).with(:update_io).ordered.and_call_original
    expect(io).to receive(:happen).with(:act_start, kind_of(Hash)).ordered
    io.happen :update_io
  end

  it 'does not send its displayed data after end' do
    act.call
    expect(io).not_to receive(:happen).with(:act_start, kind_of(Hash))
    act.happen :end
    io.happen :update_io
  end
end
