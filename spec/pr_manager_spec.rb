RSpec.describe Tarona::PrManager do
  act_class = Struct.new :io do
    include Tardvig::Events
  end

  let(:io) { Object.new.extend Tardvig::Events }
  let(:act) { act_class.new io }
  let(:msg) { double 'msg' }
  let(:job) { double 'job' }

  FakePrManager = Class.new(described_class) do
    attr_accessor :spy

    def job(event_arg)
      @spy.call(event_arg)
    end

    def job_type
      :foo
    end
  end

  let(:subj) { FakePrManager.call act: act }

  before :each do
    subj.spy = job
  end

  it 'is command' do
    expect(described_class.superclass).to be(Tardvig::Command)
  end

  it 'does its job when its event is called' do
    expect(job).to receive(:call).with(msg)
    io.happen :foo_request, msg
  end

  it 'does nothing after act is ended' do
    expect(job).not_to receive(:call)
    act.happen :end
    io.happen :foo_request, msg
  end

  it 'does not its job when another event is called' do
    expect(job).not_to receive(:call)
    io.happen :bar_request, msg
    io.happen :foo, msg
  end
end
