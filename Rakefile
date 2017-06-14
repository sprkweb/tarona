def make_task(name, description)
  task_proc = Proc.new
  task name do
    puts description + '...'
    task_proc.call
    puts
  end
end

NODEJS_BIN_PATH = './node_modules/.bin/'

is_jruby = RUBY_ENGINE == 'jruby'

build_steps = [:gems, :js_deps, :assets, :check]
build_steps << :jruby_bundle if is_jruby

task default: [:build]
task build: build_steps
task check: [:spec, :doc, :js_spec, :js_doc]

make_task :spec, 'Running specs' do
  sh 'bundle exec rspec'
end

make_task :js_spec, 'Running JavaScript specs' do
  sh NODEJS_BIN_PATH + 'testem ci -l PhantomJS'
end

make_task :doc, 'Generating documentation' do
  sh 'bundle exec yard'
end

make_task :js_doc, 'Generating JavaScript documentation' do
  sh NODEJS_BIN_PATH + 'jsdoc public/scripts/game_engine.js -d jsdoc'
end

make_task :gems, 'Installing required rubygems' do
  sh 'bundle install --path vendor/bundle'
end

make_task :js_deps, 'Installing JavaScript dependencies' do
  sh 'npm install'
end

make_task :assets, 'Installing front-end dependencies' do
  sh NODEJS_BIN_PATH + 'bower install'
end

if is_jruby
  require 'net/http'
  require 'rubygems'

  make_task :jruby_bundle, 'Making bundle with embedded JRuby' do
    version = RUBY_ENGINE_VERSION
    server_uri = 's3.amazonaws.com'
    path = "/jruby.org/downloads/#{version}/jruby-complete-#{version}.jar"
    filename = 'vendor/jruby.jar'
    download server_uri, path, filename

    sh 'bundle install --path vendor/bundle --standalone'

    pack_files = Gem::Specification.load('tarona.gemspec').files
    pack_files += Dir['.bundle/**/*', 'vendor/**/*']
    pack_files += ['Gemfile', 'Gemfile.lock']
    zip_files pack_files, 'package.zip'
  end

  def download(server_uri, path, filename)
    puts
    print "Downloading #{server_uri}/#{path}"
    Net::HTTP.start server_uri do |server|
      file = File.open filename, 'wb'
      begin
        server.request_get path do |r|
          r.read_body do |part|
            file.write part
            print '.'
          end
        end
      ensure
        file.close
      end
    end
    puts
  end

  def zip_files(list, target)
    command = "zip -@ -sf- #{target}"
    puts
    puts command
    IO.popen command, 'r+' do |io|
      list.each { |file| io.puts file }
      io.close_write
      puts io.gets
    end
  end
end
