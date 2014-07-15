$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'simplecov'

SimpleCov.minimum_coverage 60
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.order = :random
end

require 'webmock/rspec'
require 'support/request_stubbing'
require 'commander'
require 'byebug'
require 'rspec'
require 'trello'
require 'commander/trello'
require 'commander/runner'
require 'commander/client'
require 'commander/version'