describe Tarona::Toolkit do
  def construct_io(settings)
    io = double
    allow(io).to receive(:read) { YAML.dump settings }
    allow(io).to receive(:write)
    io
  end

  def empty_io
    construct_io({})
  end

  def empty_options
    {
      default_settings: empty_io,
      settings: empty_io,
      i18n: empty_io
    }
  end

  def toolkit(options)
    described_class.new empty_options.merge(options)
  end

  describe '#settings' do
    let(:default) { { default_included: true, overwritten: false } }
    let(:custom) { { overwritten: true } }
    let(:default_io) { construct_io default }
    let(:custom_io) { construct_io custom }

    it 'loads default settings' do
      tk = toolkit(default_settings: default_io)
      expect(tk.settings[:default_included]).to be true
      expect(tk.settings[:overwritten]).to be false
    end

    it 'overwrites default settings with custom if they are' do
      tk = toolkit default_settings: default_io, settings: custom_io
      expect(tk.settings[:default_included]).to be true
      expect(tk.settings[:overwritten]).to be true
    end

    it 'checks whether the custom settings exist before loading' do
      expect(File).to receive(:exist?).with(described_class::SETTINGS_PATH) do
        false
      end
      described_class.new default_settings: default_io, i18n: empty_io
    end
  end

  describe '#i18n' do
    let(:t9n) { construct_io hello: 'Привет' }

    it 'loads translation from YAML' do
      tk = toolkit i18n: t9n
      expect(tk.i18n[:hello]).to eq('Привет')
    end
  end
end