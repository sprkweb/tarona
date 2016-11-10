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
end
