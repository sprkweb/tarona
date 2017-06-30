RSpec.describe Tarona::Game::HudSupport::Informer do
  let(:io) { Object.new.extend(Tardvig::Events) }
  let(:act) { double 'act' }
  let(:rules) { double 'rules' }
  let(:tick_counter) { Object.new.extend(Tardvig::Events) }

  before :each do
    allow(act).to receive(:rules).and_return(rules)
    allow(act).to receive(:io).and_return(io)
    allow(rules).to receive(:tick_counter).and_return(tick_counter)
    described_class.call act: act
  end

  it 'is command' do
    expect(described_class.ancestors).to include(Tardvig::Command)
  end

  it 'sends the tick_start event to IO when it happens' do
    arg = double
    expect(act.io).to receive(:happen).with(:tick_start, arg)
    tick_counter.happen :tick_start, arg
  end
end
