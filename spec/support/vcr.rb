# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  if ENV.key?('GITHUB_API_TOKEN')
    config.filter_sensitive_data('<GITHUB_API_TOKEN>') do
      ENV['GITHUB_API_TOKEN']
    end
  end
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
  config.default_cassette_options = { record: :new_episodes }
end
