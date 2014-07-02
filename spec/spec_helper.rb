require 'simplecov'

SimpleCov.minimum_coverage 60
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.order = :random
end