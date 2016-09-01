RSpec.describe 'Web pages' do
  include Rack::Test::Methods

  def app
    Tarona::WebServer
  end

  before :each do
    @old_tk = app.tk
    app.tk = double 'toolkit'
    i18n = double 'i18n'
    allow(app.tk).to receive(:i18n) { i18n }
    allow(i18n).to receive(:[]) { {} }
  end

  after :each do
    app.tk = @old_tk
  end

  it 'should compile SCSS files' do
    get '/styles/main'
    expect(last_response.status).to eq(200)
    expect(last_response.headers['content-type']).to start_with('text/css')
  end

  describe '/' do
    it 'is HTML' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to start_with('text/html')
    end

    it 'includes game name as a title' do
      expect(app.tk.i18n).to receive(:[]).with('game_name') { 'foo' }
      get '/'
      expect(last_response.body).to include('<title>foo</title>')
    end

    it 'includes link to play' do
      get '/'
      expect(last_response.body).to match(/href=("|')\/play("|')/)
    end
  end

  describe '/play' do
    it 'is HTML' do
      get '/play'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to start_with('text/html')
    end

    it 'includes game name as a title' do
      expect(app.tk.i18n).to receive(:[]).with('game_name') { 'foo' }
      get '/play'
      expect(last_response.body).to include('<title>foo</title>')
    end
  end
end