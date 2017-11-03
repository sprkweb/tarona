require File.expand_path(File.dirname(__FILE__) + '/lib/tarona/version.rb')

Gem::Specification.new do |s|
  s.name = 'tarona'
  s.version = Tarona::VERSION
  s.summary = 'Fantasy strategic game'
  s.description = <<DOC
Fantasy strategic game about society management.
DOC
  s.homepage = 'https://github.com/sprkweb/tarona'
  s.authors = ['Vadim Saprykin', 'Leonid Marychev']
  s.email = 'sprkweb@ya.ru'
  s.files = Dir[
      'bin/**/*',
      'game/**/*',
      'lib/**/*',
      'public/**/*',
      'views/**/*'
    ] + [
      'LICENSE',
      'README.md'
    ]
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'tardvig', '~> 0.3.2'
  s.add_runtime_dependency 'rack', '~> 1.4'
  s.add_runtime_dependency 'puma', '~> 3.6'
  s.add_runtime_dependency 'sinatra', '~> 1.4'
  s.add_runtime_dependency 'faye-websocket', '~> 0.10'
  s.add_runtime_dependency 'sass', '~> 3.4'
  s.add_runtime_dependency 'erubis', '~> 2.7'

  s.add_development_dependency 'rake', '>= 10.0.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'kramdown', '~> 1.12'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'rack-test', '~> 0.6'
end
