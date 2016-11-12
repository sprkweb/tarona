RSpec.describe Tarona::Doorman do
  let(:io) { double }
  let(:io_instance) { double }
  let(:server) { double }
  let(:game) { double }
  let(:options) { { valid: true } }
  let(:env) { double }
  let :doorman do
    described_class.new(
        io: io,
        server: server,
        game: game,
        game_options: options
    )
  end

  before :example do
    allow(io).to receive(:new).with(env) { io_instance }
    allow(io_instance).to receive(:on_first) do |event, &block|
      if event == :open
        block.call
      else
        raise "Unexpected event: #{event.inspect}"
      end
    end
    allow(io_instance).to receive(:response) { 'foo' }
  end

  describe '#call' do
    # TODO: Refactor
    it 'gives care of connection to the server if it is not WebSocket' do
      expect(io).to receive(:player?).with(env) { false }
      expect(server).to receive(:call).with(env)
      doorman.call env
    end

    it 'starts a new game if it is WebSocket' do
      expect(io).to receive(:player?).with(env).ordered { true }
      expect(io).to receive(:new).with(env).ordered { io_instance }
      expect(game).to receive(:call).with(
        hash_including(io: io_instance, valid: true)
      )
      expect(io_instance).to receive(:response) { 'foo' }
      expect(doorman.call(env)).to eq('foo')
    end
  end

  it 'stores game sessions with their hashes' do
    expect(doorman.sessions).to eq({})
    expect(io).to receive(:player?) { true }
    game_inst = double 'game_inst'
    expect(game).to receive(:call) { game_inst }
    doorman.call env
    expect(doorman.sessions).to eq game_inst.hash => game_inst
  end
end
