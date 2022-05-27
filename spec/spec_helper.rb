# frozen_string_literal: true

require 'rails'
require_relative '../lib/onesignal/rails/plugin'

APP_KEY = 'TEST_API_KEY'
APP_ID = '00000000-0000-0000-0000-000000000000'

RSpec.configure do |config|
  config.before(:each) do |_example|
    OneSignal::Rails::Plugin.configure do |c|
      c.app_key = APP_KEY
      c.app_id = APP_ID
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
