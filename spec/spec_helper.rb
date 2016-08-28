require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative '../lib/tarona.rb'
require 'game/game'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
