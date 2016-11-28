RSpec.describe Tarona::Action do
  it 'is act type' do
    expect(described_class.superclass).to be(Tarona::Act)
  end

  it 'consists of player\'s action' do
    expect(described_class.act_type).to be(:action)
  end

  class TestAction < Tarona::Action
    LANDSCAPE = Landscape.new [[{}, {}]]
    subject landscape: LANDSCAPE
    hex_size 15
  end

  class TestAction2 < TestAction
    subject landscape: proc { LANDSCAPE }
    hex_size 15
  end

  let(:io) { Tardvig::GameIO.new }
  let(:act) { TestAction.new io: io }

  after :each do
    TestAction.resources.clear
  end

  it 'notifies IO with some data' do
    expect(io).to receive(:happen).with(
      :act_start,
      type: :action,
      subject: hash_including(
        landscape: TestAction::LANDSCAPE.raw,
        hex_size: TestAction.hex_size
      )
    )
    act.call
  end

  it 'can receive proc which returns landscape instead of landscape' do
    act = TestAction2.new io: io
    expect(io).to receive(:happen).with(
      :act_start,
      hash_including(
        subject: hash_including(landscape: TestAction::LANDSCAPE.raw)
      )
    )
    act.call
  end

  it 'allows to set resources' do
    expect(TestAction.resources).to eq([])
    TestAction.resources << 'myfile.svg'
    expect(TestAction.resources).to eq(['myfile.svg'])
  end

  it 'send resources with other information' do
    TestAction.resources << 'spec/helpers/myfile.svg'
    TestAction.resources << 'spec/helpers/good_things.svg'
    expect(io).to receive(:happen).with(
      :act_start,
      hash_including(subject: hash_including(
        dependencies: "<g>Some SVG markup here</g>\n<g>Good things.</g>\n"
      ))
    )
    act.call
  end
end
