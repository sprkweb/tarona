require 'rubygems'
require 'bundler/setup'

require_jasmine = proc do
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
  task :js_spec do
    puts 'Running JavaScript specs...'
    Rake::Task[:'jasmine:ci'].invoke
    puts ''
  end
end

task default: [:build]
task build: [:gems, :js_deps, :assets, :check]
task check: [:spec, :doc, :js_spec, :js_doc]

task :spec do
  puts 'Running specs...'
  sh 'bundle exec rspec'
  puts ''
end

task :doc do
  puts 'Generating documentation...'
  sh 'bundle exec yard'
  puts ''
end

task :js_doc do
  puts 'Generating JavaScript documentation...'
  sh './node_modules/.bin/jsdoc game_engine.js -d jsdoc'
  puts ''
end

task :gems do
  puts 'Installing required rubygems...'
  sh 'bundle install --path vendor/bundle'
  puts ''
  require_jasmine.call
end

task :js_deps do
  puts 'Installing JavaScript dependencies...'
  sh 'npm install'
  puts ''
end

task :assets do
  puts 'Installing front-end dependencies...'
  sh './node_modules/.bin/bower install'
  puts ''
end

if Gem::Specification::find_all_by_name('jasmine').any?
  require_jasmine.call
end
