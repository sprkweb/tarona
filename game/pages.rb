module Tarona
  class WebServer
    configure do
      mime_type :js, 'application/javascript'
    end

    get '/' do
      content = erb :menu, locals: { menu_items: [
        ['/play', tk.i18n['menu/continue']]
      ] }
      page_options = {
        title: tk.i18n['game_name'],
        content: content,
        styles: ['styles/main']
      }
      erb :page, layout: :index, locals: { options: page_options }
    end

    get '/play' do
      page_options = {
        title: tk.i18n['game_name'],
        styles: ['styles/play'],
        scripts: {
          after: [
            'vendor/underscore/underscore-min.js',
            'scripts/game_engine.js',
            ('scripts?' +
              %w[
                action/scripts/highlight_hexes.js
                action/scripts/fov_operator.js
                action/scripts/player_interact.js
                action/scripts/hud.js
              ].map { |x| "s[]=#{x}" }.join('&')
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
