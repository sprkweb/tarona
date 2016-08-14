require File.expand_path(File.dirname(__FILE__) + '/lib/tarona/version.rb')

Gem::Specification.new do |s|
  s.name = 'tarona'
  s.version = Tarona::VERSION
  s.summary = ''
  s.description = <<DOC
DOC
  s.homepage = ''
  s.author = 'Vadim Saprykin'
  s.email = 'sprkweb@ya.ru'
  s.files = ['lib/tarona.rb']
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.0.0'
  s.add_development_dependency 'rake', '~> 11.2'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'redcarpet', '~> 3.3'
  s.add_development_dependency 'simplecov', '~> 0.12.0'
end
