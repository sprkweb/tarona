def make_task(name, description)
  task_proc = Proc.new
  task name do
    puts description + '...'
    task_proc.call
    puts
  end
end

NODEJS_BIN_PATH = './node_modules/.bin/'

task default: [:build]
task build: [:gems, :js_deps, :assets, :check]
task check: [:spec, :doc, :js_spec, :js_doc]

make_task :spec, 'Running specs' do
  sh 'bundle exec rspec'
end

make_task :js_spec, 'Running JavaScript specs' do
  sh NODEJS_BIN_PATH + 'testem ci'
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
