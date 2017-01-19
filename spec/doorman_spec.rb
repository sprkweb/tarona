RSpec.describe Tarona::Doorman do
  %w(io io_instance server game game_inst env).each do |o|
    let(o.to_sym) { double o }
  end
  let(:options) { { valid: true } }
  let(:socket) { double 'socket' }
  let(:display_options) { {} }
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
      events = [:display_ready]
      raise "Unexpected event: #{event.inspect}" unless events.include? event
      block.call display_options
    end
    allow(io_instance).to receive(:happen) do |event|
      events = [:new_session]
      raise "Unexpected event: #{event.inspect}" unless events.include? event
    end
    allow(io_instance).to receive(:response) { 'foo' }
    allow(io_instance).to receive(:socket) {}
    allow(game).to receive(:call) { game_inst }
    allow(game_inst).to receive(:io) { io_instance }
  end

  describe '#call' do
    it 'gives care of connection to the server if it is not WebSocket' do
      expect(io).to receive(:player?).with(env) { false }
      expect(server).to receive(:call).with(env)
      doorman.call env
    end

    it 'starts a new game if it is WebSocket' do
      expect(io).to receive(:player?).with(env).ordered { true }
      expect(io).to receive(:new).with(env).ordered { io_instance }
      expect(game).to receive(:call).with(io: io_instance, valid: true)
      expect(io_instance).to receive(:response) { 'foo' }
      expect(doorman.call(env)).to eq('foo')
    end

    it 'send session hash through io if there is new one' do
      expect(io).to receive(:player?) { true }
      expect(io_instance).to receive(:happen).with(
        :new_session, hash: game_inst.hash.to_s(16)
      )
      doorman.call env
    end

    it 'use old session if it is' do
      new_socket = io_instance.socket
      expect(io).to receive(:player?).and_return(true).twice
      doorman.call env
      display_options[:session_id] = game_inst.hash.to_s(16)
      expect(io_instance).not_to receive(:happen)
      expect(io_instance).to receive(:socket=).with(new_socket)
      doorman.call env
    end

    it 'does not use old session unless it is given' do
      expect(io).to receive(:player?).and_return(true).twice
      doorman.call env
      expect(io_instance).to receive(:happen)
      expect(io_instance).not_to receive(:socket=)
      doorman.call env
    end

    it 'does not use old session unless it exists' do
      expect(io).to receive(:player?).and_return(true).twice
      doorman.call env
      display_options[:session_id] = 'foobarbaz'
      expect(io_instance).to receive(:happen)
      expect(io_instance).not_to receive(:socket=)
      doorman.call env
    end

    it 'loads saved session if it exists' do
      expect(io).to receive(:player?) { true }
      expect(game).to receive(:call).with(
        io: io_instance, valid: true, saved_data: :foo
      )
      display_options[:saved_session] = :foo
      doorman.call(env)
    end
  end

  it 'stores game sessions with their hashes' do
    expect(doorman.sessions).to eq({})
    expect(io).to receive(:player?) { true }
    doorman.call env
    expect(doorman.sessions).to eq game_inst.hash.to_s(16) => game_inst
  end
end
