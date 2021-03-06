RSpec.describe Tarona::Game::HudSupport do
  let(:act) { double 'act' }
  let(:session) { double 'session' }

  it 'is command' do
    expect(described_class.ancestors.include?(Tardvig::Command)).to be true
  end

  it 'calls its parts' do
    c = described_class
    parts = [c::Informer, c::EntityInfo, c::MovementPotential]
    parts.each do |part|
      expect(part).to receive(:call).with(act: act, session: session)
    end
    described_class.call act: act, session: session
  end
end
