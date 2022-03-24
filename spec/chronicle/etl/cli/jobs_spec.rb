require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Jobs do
  let(:csv_filename) { "spec/support/sample_data/test.csv" }
  let(:csv_job_args) do
    %w[
      --extractor csv
      --log-level fatal
      --extractor-opts
    ] << "input:#{csv_filename}"
  end

  describe "chronicle-etl jobs:run" do
    it "run a simple job" do
      file_record_count = File.read(csv_filename).each_line.count - 1

      args = ['jobs:run'] << csv_job_args
      output, = invoke_cli(args)

      # records + table header row
      expect(output.split("\n").count).to eql(file_record_count + 1)
    end
  end

  describe "chronicle-etl jobs:show" do
    it "shows details about a simple job" do
      args = ['jobs:show'] << csv_job_args
      output, = invoke_cli(args)

      expect(output).to match(/Extracting from/)
      expect(output).to match(/Transforming/)
      expect(output).to match(/Loading/)
      # TODO: do more precise matching based on job
    end
  end

  describe "chronicle-etl jobs:list" do
    include_context "mocked config directory"

    it "lists available jobs" do
      output, = invoke_cli(%w[jobs list])
      expect(output.split("\n").last).to match('^  command')
    end
  end

  describe "chronicle-etl jobs help" do
    it "outputs help for jobs" do
      expect(invoke_cli(%w[jobs help]).first).to match(/COMMANDS/)
    end

    it "outputs help for a job subcommand" do
      expect(invoke_cli(%w[jobs help show]).first).to match(/Usage:/)
    end
  end
end
