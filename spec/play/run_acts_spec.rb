RSpec.describe Tarona::Play::RunActs do
  class TestAct < Tarona::Act
    def self.ended
      @ended ||= []
    end

    def process
      TestAct.ended << self
      happen :end, next_act
    end

    private

    def next_act
      nil
    end

    def notify_display
    end
  end

  class FirstAct < TestAct
    def next_act
      :second
    end
  end

  class SecondAct < TestAct
    def next_act
      :third
    end
  end

  class ThirdAct < TestAct
  end


  let(:act_params) { { valid: true } }
  let(:acts) { { first: FirstAct, second: SecondAct, third: ThirdAct } }
  let :subject do 
    described_class.new act_params: act_params, acts: acts, first_act: :first
  end

  describe '#call' do
    it 'creates a new thread for it' do
      instance = subject.call
      expect(instance.thread).to be_a(Thread)
      instance.thread.join
    end

    it 'executes every act' do
      expect(TestAct.ended).to receive(:<<).with(kind_of(FirstAct)).ordered
      expect(TestAct.ended).to receive(:<<).with(kind_of(SecondAct)).ordered
      expect(TestAct.ended).to receive(:<<).with(kind_of(ThirdAct)).ordered
      subject.call.thread.join
    end

    it 'passes act_params as an option to acts' do
      expect(TestAct.ended).to receive(:<<).exactly(3).times do |act|
        expect(act.valid).to be true
      end
      subject.call.thread.join
    end
  end
end