require "bundler/gem_tasks"

desc 'Run Rubocop'
task :rubocop do
  sh 'bundle exec rubocop -c rubocop.yml'
end

task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end

desc 'Increase version of a gem'
task :bump do
  sh 'gem bump --no-commit'
end
