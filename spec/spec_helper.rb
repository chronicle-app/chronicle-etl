require 'simplecov'
SimpleCov.start

require "bundler/setup"
require "chronicle/etl"
require "chronicle/etl/cli"

require_relative "support/invoke_cli"
require_relative "support/run_extraction"
require_relative "support/mocked_config_directory"
require_relative "support/mocked_stdin"

RSPEC_ROOT = File.dirname(__FILE__)

RSpec.configure do |config|
  config.include Chronicle::ETL::SpecHelpers
  config.include_context "mocked config directory", :include_shared => true
  config.include_context "mocked stdin", :include_shared => true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Adapted from minitest
  # https://github.com/seattlerb/minitest/blob/7d2134a1d386a068f1c7705889c7764a47413861/lib/minitest/assertions.rb#L514
  def capture
    require "stringio"
    orig_stdout = $stdout
    orig_stderr = $stderr

    captured_stdout = StringIO.new
    captured_stderr = StringIO.new

    $stdout = captured_stdout
    $stderr = captured_stderr

    yield

    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
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
