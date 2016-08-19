RSpec.describe Tarona::Doorman do
  let(:io) { double }
  let(:server) { double }
  let(:game) { double }
  let(:acts) { double }
  let(:first_act) { double }
  let(:env) { double }
  let :doorman do
    described_class.new(
        io: io,
        server: server,
        game: game,
        acts: acts,
        first_act: first_act
    )
  end

  describe '#call' do
    it 'gives care of connection to the server if it is not WebSocket' do
      expect(io).to receive(:player?).with(env) { false }
      expect(server).to receive(:call).with(env)
      doorman.call env
    end

    it 'starts a new game if it is WebSocket' do
      io_instance = double
      expect(io).to receive(:player?).with(env).ordered { true }
      expect(io).to receive(:new).with(env).ordered { io_instance }
      expect(game).to receive(:new).with(hash_including(
          io: io_instance,
          acts: acts,
          first_act: first_act
      ))
      doorman.call env
    end
  end
end