RSpec.describe Tarona::Play do
  [:io, :tk, :tk_inst, :acts, :first_act, :session].each do |obj|
    let(obj) { double(obj.to_s) }
  end
  let(:run_acts_opts) { { io: io, acts: acts, first_act: first_act, tk: tk } }
  let :subject do
    described_class.new run_acts_opts
  end

  before :example do
    allow(tk).to receive(:new).and_return(tk_inst)
    allow(tk_inst).to receive(:session).and_return(session)
    allow(io).to receive(:spy_on)
    allow(io).to receive(:on)
  end

  it 'runs acts in a cycle' do
    expect(described_class::RunActs).to receive(:call).with(
      hash_including(
        acts: acts,
        first_act: first_act,
        session: session,
        act_params: hash_including(tk: tk_inst, io: io)
      )
    )
    subject.call
  end

  it 'creates an instance of toolkit' do
    expect(tk).to receive(:new)
    subject.call
  end

  it 'can load saved session' do
    saved_data = Object.new
    expect(session).to receive(:load).with(saved_data)
    subject.call saved_data: saved_data
  end

  it 'does not load saved session if it is not given' do
    expect(session).not_to receive(:load)
    subject.call
  end

  it 'can save current session when it is requested' do
    callback = nil
    expect(io).to receive(:on).with(:save).once do |*_, &block|
      callback = block
    end
    subject.call
    saved_data = Object.new
    expect(session).to receive(:save).with(saved_data)
    callback.call saved_data
  end
end
