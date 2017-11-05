module Tarona
  class WebServer
    configure do
      mime_type :js, 'application/javascript'
    end

    get '/' do
      legal = ''
      File.read('LICENSE').each_line do |line|
        next unless line.start_with?('Copyright')
        legal = line.gsub(/\(c\)/, '&copy;')
        break
      end
      page_options = {
        title: tk.i18n['game_name'],
        legal: legal,
        menu_items: [
          ['/play', tk.i18n['menu/continue']],
          ['/new_game', tk.i18n['menu/new_game']]
        ],
        styles: ['styles/main']
      }
      erb :main_menu, layout: :index, locals: { options: page_options }
    end

    get '/new_game' do
      erb(:index, locals: {
        options: { title: '', scripts: { before: ['scripts/new_game.js'] } }
      }) {}
    end

    get '/play' do
      page_options = {
        title: tk.i18n['game_name'],
        styles: ['styles/play'],
        scripts: {
          after: [
            'vendor/underscore/underscore-min.js',
            'vendor/velocity/velocity.min.js',
            'scripts/game_engine.js',
            ('scripts?' +
              (Dir.chdir 'public/scripts' do
                Dir['action/scripts/*.js'].map { |x| "s[]=#{x}" }.join('&')
              end)
            ),
            'scripts/runner.js'
          ]
        }
      }
      erb :game, layout: :index, locals: { options: page_options }
    end

    get '/styles/:name' do
      scss :"styles/#{params[:name]}"
    end

    get '/scripts' do
      content_type :js
      if params['s'].is_a?(Array)
        params['s']
          .map { |s| File.read(File.join('public', 'scripts', s)) }
          .join
      else
        ''
      end
    end
  end
end
