task default: [:build]
task build: [:gems, :assets, :check]
task check: [:spec, :doc]

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

task :gems do
  puts 'Installing required rubygems...'
  sh 'bundle install --path vendor/bundle'
  puts ''
end

task :assets do
  puts 'Installing front-end dependencies...'
  # TODO: I need something to install front-end dependencies, such as Bower,
  # but without Node.js
  puts ''
end