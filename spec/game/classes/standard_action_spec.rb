RSpec.describe Tarona::Game::StandardAction do
  empty_command = Class.new(Tardvig::Command) do
    include Tardvig::Events
    def process; end
  end

  let(:tk) { double 'tk' }
  let(:rules) { |*args| empty_command.new(*args) }
  let :params do
    { io: Object.new.extend(Tardvig::Events), tk: tk }
  end
  test_act = nil

  before :each do
    allow(tk).to receive(:session).and_return(act_inf: {})
    allow(tk).to receive(:i18n).and_return({})
    allow(Tarona::Game::StandardRules).to receive(:call) do |*args|
      empty_command.new(*args)
    end
    allow(Tarona::Game::HudSupport).to receive(:call) do |*args|
      empty_command.new(*args)
    end
    allow(File).to receive(:read)
      .and_return("map: \n  - - {}\nentities: :baz")
    test_act = Class.new(described_class) do
      name :foo
    end
  end

  it 'is action' do
    expect(test_act.ancestors).to include(Tarona::Action)
  end

  it 'has default value for hex_size' do
    expect(test_act.hex_size).to eq 15
  end

  it 'has default SVG resources' do
    expect(test_act.resources).to eq ['game/resources/style.svg']
  end

  it 'has the read-write #name attribute' do
    expect(test_act.name).to eq :foo
  end

  it 'loads subject from a file' do
    expect(Tarona::Action::Landscape).to receive(:new)
      .with([[{}]]).and_return(:map)
    expect(test_act.subject[:landscape].call).to be :map
    expect(test_act.subject[:entities_index].call).to be :baz
  end

  it 'calls StandardRules' do
    act = test_act.call params
    expect(Tarona::Game::StandardRules).to have_received(:call)
    expect(act.rules.act).to be(act)
    expect(act.rules.session).to be(params[:tk].session)
  end

  it 'calls HudSupport' do
    act = test_act.call params
    expect(Tarona::Game::HudSupport).to have_received(:call)
      .with(act: act, session: params[:tk].session)
  end

  it 'includes additional data in the client notification' do
    allow(tk).to receive(:session).and_return(
      act_inf: {
        tick: 3,
        landscape: Struct.new(:raw).new([]),
        entities_index: {}
      }
    )
    expect(params[:io]).to receive(:happen).with(
      :act_start,
      hash_including(
        subject: hash_including(
          tick: 3
        )
      )
    )
    test_act.call params
  end
end
