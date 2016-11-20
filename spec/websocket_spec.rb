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

  MockSocket = Class.new do
    def listeners
      @listeners ||= []
    end

    def on(event, &block)
      listeners << [event, block]
    end

    def rack_response
      'foo'
    end
  end

  let(:io) { described_class.new env }
  let(:socket) { MockSocket.new }
  let(:socket2) { MockSocket.new }
  before(:example) do
    allow(Faye::WebSocket).to receive(:new) { socket }
  end

  shared_examples 'socket-based methods' do |&settings|
    instance_eval(&settings) if settings

    it 'converts output events to JSON' do
      expect(socket).to receive(:send) do |args|
        expect(JSON.parse(args)).to match_array(%w(event args))
      end
      io.happen :event, 'args'
    end

    it 'converts input JSON to events' do
      listener = proc {}
      io.on :event, &listener
      expect(listener).to receive(:call).with('args')
      event = double
      expect(event).to receive(:data) { JSON.dump [:event, 'args'] }
      socket.listeners.each do |l|
        l[1].call event if l[0] == :message
      end
    end

    describe '#response' do
      it 'returns rack response to make the connection' do
        expect(io.response).to eq('foo')
      end
    end

    it 'triggers the `open` event when a connection is opened' do
      listener = proc {}
      io.on :open, &listener
      expect(listener).to receive(:call)
      socket.listeners.each do |l|
        l[1].call if l[0] == :open
      end
    end
  end

  include_examples('socket-based methods') {}
  context 'with changed socket' do
    include_examples 'socket-based methods' do
      before(:example) do
        allow(Faye::WebSocket).to receive(:new) { socket2 }
      end
      let(:io) do
        subj = described_class.new env
        subj.socket = socket
        subj
      end
    end
  end

  it 'triggers `update_io` when socket is changed' do
    listener = proc {}
    expect(listener).to receive(:call)
    io.on :update_io, &listener
    io.socket = socket
  end
end
