require 'simplecov'

SimpleCov.minimum_coverage 60
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.order = :random
end

require 'support/request_stubbing'
require 'commander'
require 'byebug'
require 'webmock/rspec'
require 'rspec'
require 'trello'
require 'commander/trello'
require 'commander/client'