$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'simplecov'

SimpleCov.minimum_coverage 60
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.order = :random
  c.before { allow($stdout).to receive(:puts) }
end

require 'webmock/rspec'
require 'support/request_stubbing'
require 'support/input_stubbing'
require 'commander'
require 'rspec'
require 'trello'
require 'commander/trello'
require 'commander/runner'
require 'commander/client'
require 'commander/version'

