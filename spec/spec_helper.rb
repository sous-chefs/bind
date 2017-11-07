# frozen_string_literal: true
require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }

RSpec.configure(&:raise_errors_for_deprecations!)
# RSpec.configure do |config|
#   config.cookbook_path = 'test/fixtures/cookbooks'
# end
