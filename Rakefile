def make_task(name, description)
  task_proc = Proc.new
  task name do
    puts description + '...'
    run_task task_proc
    puts
  end
end

def run_task(task_proc)
  failed = 0
  begin
    task_proc.call
  rescue Exception => e
    failed += 1
    if failed < 3
      puts 'Failed. Try again...'
      retry
    else
      raise e
    end
  end
end

task default: [:build]
task build: [:gems, :js_deps, :assets, :check]
task check: [:spec, :doc, :js_spec, :js_doc]

make_task :spec, 'Running specs' do
  sh 'bundle exec rspec'
end

jasmine_required = false
make_task :js_spec, 'Running JavaScript specs' do
  unless jasmine_required
    require 'rubygems'
    require 'bundler/setup'
    require 'jasmine'
    load 'jasmine/tasks/jasmine.rake'
    jasmine_required = true
  end
  Rake::Task[:'jasmine:ci'].invoke
end

make_task :doc, 'Generating documentation' do
  sh 'bundle exec yard'
end

make_task :js_doc, 'Generating JavaScript documentation' do
  sh './node_modules/.bin/jsdoc public/scripts/game_engine.js -d jsdoc'
end

make_task :gems, 'Installing required rubygems' do
  sh 'bundle install --path vendor/bundle'
end

make_task :js_deps, 'Installing JavaScript dependencies' do
  sh 'npm install'
end

make_task :assets, 'Installing front-end dependencies' do
  sh './node_modules/.bin/bower install'
end
