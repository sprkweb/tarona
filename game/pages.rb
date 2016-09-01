module Tarona
  class WebServer
    get '/' do
      content = erb :menu, locals: { menu_items: [
        ['/play', tk.i18n['menu']['continue']]
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
          # after: %w[vendor/scripts/underscore.js scripts/game_engine.js]
        }
      }
      erb :game, layout: :index, locals: { options: page_options }
    end

    get '/styles/:name' do
      scss :"styles/#{params[:name]}"
    end
  end
end
