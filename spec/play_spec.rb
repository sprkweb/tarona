RSpec.describe Tarona::Play do
  [:io, :tk, :acts, :first_act].each { |obj| let(obj) { double } }
  let(:run_acts_opts) { { io: io, acts: acts, first_act: :first, tk: tk } }
  let :subject do 
    described_class.new run_acts_opts
  end
  
  it 'runs acts in a cycle' do
    expect(described_class::RunActs).to receive(:call).with(run_acts_opts)
    subject.call
  end
end