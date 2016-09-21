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


  let(:io) { double }
  let(:tk) { double }
  let(:acts) { { first: FirstAct, second: SecondAct, third: ThirdAct } }
  let :subject do 
    described_class.new io: io, acts: acts, first_act: :first, tk: tk
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

    it 'passes io as an option' do
      expect(TestAct.ended).to receive(:<<).exactly(3).times do |act|
        expect(act.io).to be(io)
      end
      subject.call.thread.join
    end

    let(:toolkit) { double }

    it 'passes toolkit as an option if it is' do
      expect(TestAct.ended).to receive(:<<).exactly(3).times do |act|
        expect(act.tk).to be(toolkit)
      end
      subject.call(tk: toolkit).thread.join
    end
  end
end