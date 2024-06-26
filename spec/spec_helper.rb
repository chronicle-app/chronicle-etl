# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'chronicle/etl'
require 'chronicle/etl/cli'

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.allow_http_connections_when_no_cassette = true
  config.hook_into :webmock
  config.filter_sensitive_data('<TOKEN>') { Gem.configuration.rubygems_api_key }
end

require_relative 'support/capture_io'
require_relative 'support/invoke_cli'
require_relative 'support/mocked_config_directory'
require_relative 'support/mocked_stdin'
require_relative 'support/run_extraction'
require_relative 'support/wait_until'

RSPEC_ROOT = File.dirname(__FILE__)

RSpec.configure do |config|
  config.include Chronicle::ETL::SpecHelpers
  config.include_context 'mocked config directory', include_shared: true
  config.include_context 'mocked stdin', include_shared: true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.mock_with :rspec

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
# This monkeypatch is required because of weird interactions between the
# `tty-screen` used for CLI output and the way rspec captures stdout
# see: https://github.com/rspec/rspec-expectations/issues/1305
# and: https://github.com/emsk/bundle_outdated_formatter/blob/v0.7.0/spec/spec_helper.rb#L16-L21
require 'stringio'
class StringIO
  def ioctl(*)
    0
  end
end
