#!/usr/bin/env rake

# chefspec task against spec/*_spec.rb
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:chefspec)

# foodcritic rake task
desc 'Foodcritic linter'
task :foodcritic do
  sh 'foodcritic -f correctness .'
end

# rubocop rake task
desc 'Ruby style guide linter'
task :cookstyle do
  sh 'cookstyle'
end

# Deploy task
desc 'Deploy to chef server and pin to environment'
task :deploy do
  sh 'berks upload bind'
  sh 'berks apply production'
end

# default tasks are quick, commit tests
task default: %w(foodcritic cookstyle chefspec)

# jenkins tasks format for metric tracking
task jenkins: %w(foodcritic cookstyle chefspec)
