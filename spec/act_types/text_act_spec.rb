RSpec.describe Tarona::TextAct do
  it 'is act type' do
    expect(described_class.superclass).to be(Tarona::Act)
  end

  it 'consists of text' do
    expect(described_class.act_type).to be(:text)
  end

  class TestTextAct < Tarona::TextAct
    subject 'mystring'
  end

  let(:io) { Tardvig::GameIO.new }
  let(:act) { TestTextAct.new io: io}

  it 'notifies IO with its text' do
    expect(io).to receive(:happen).with(:act_start, hash_including(
        type: :text,
        subject: 'mystring'
    ))
    act.call
  end

  it 'starts next act when it is requested' do
    act.call
    expect(act).to receive(:happen).with(:end, any_args)
    io.happen :read
  end

  class TestTextAct
    def next_act
      :foo
    end
  end

  it 'takes a name of next act from method' do
    act.call
    expect(act).to receive(:happen).with(:end, :foo)
    io.happen :read
  end
end