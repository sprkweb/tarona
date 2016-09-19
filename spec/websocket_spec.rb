RSpec.describe Tarona::WebSocket do
  let(:env) { double }

  it 'is implementation of Tardvig::GameIO' do
    expect(described_class.ancestors).to include(Tardvig::GameIO)
  end

  describe '#player?' do
    it 'checks whether it is websocket connection' do
      boolean = double
      expect(Faye::WebSocket).to receive(:websocket?).with(env) { boolean }
      expect(described_class.player?(env)).to be(boolean)
    end
  end

  it 'is event-driven wrapper of Faye::WebSocket' do
    expect(Faye::WebSocket).to receive(:new).with(env) { spy }
    described_class.new env
  end

  let(:io) { described_class.new env }
  let(:socket) { double }
  before(:example) do
    allow(socket).to receive(:listeners) { @listeners }
    allow(socket).to receive(:on) do |event, &block|
      @listeners ||= []
      @listeners << [event, block]
    end
    allow(socket).to receive(:rack_response) { 'foo' }
    allow(Faye::WebSocket).to receive(:new) { socket }
  end

  it 'converts output events to JSON' do
    expect(socket).to receive(:send) do |args|
      expect(JSON.parse(args)).to match_array(['event', 'args'])
    end
    io.happen :event, 'args'
  end

  it 'converts input JSON to events' do
    listener = proc {}
    io.on :event, &listener
    expect(listener).to receive(:call).with('args')
    event = double
    expect(event).to receive(:data) { JSON.dump [:event, 'args'] }
    socket.listeners.each do |listener|
      next unless listener[0] == :message
      listener[1].call event
    end
  end
  
  describe '#response' do
    it 'returns rack response to make the connection' do
      expect(io.response).to eq('foo')
    end
  end
end
