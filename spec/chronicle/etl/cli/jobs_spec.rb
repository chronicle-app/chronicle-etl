require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Jobs do
  let(:csv_filename) { "spec/support/sample_data/test.csv" }
  let(:csv_job_args) do
    %w[
      --extractor csv
      --log-level fatal
      --extractor-opts
    ] << "filename:#{csv_filename}"
  end

  describe "chronicle-etl jobs:run" do
    it "run a simple job" do
      file_record_count = File.read(csv_filename).each_line.count - 1

      args = ['jobs:run'] << csv_job_args
      output = invoke_cli(args)

      expect(output.split("\n").count).to eql(file_record_count)
    end
  end

  describe "chronicle-etl jobs:show" do
    it "shows details about a simple job" do
      args = ['jobs:show'] << csv_job_args
      output = invoke_cli(args)

      expect(output).to match(/Extracting from/)
      expect(output).to match(/Transforming/)
      expect(output).to match(/Loading/)
      # TODO: do more precise matching based on job
    end
  end

  describe "chronicle-etl jobs:show" do
    xit "lists available jobs" do
      invoke_cli(['jobs:list'])
      # TODO: have mock filesystem for job definitions
    end
  end

  describe "chronicle-etl jobs help" do
    it "outputs help for jobs" do
      expect(invoke_cli(%w[jobs help])).to match(/COMMANDS/)
    end

    it "outputs help for a job subcommand" do
      expect(invoke_cli(%w[jobs help show])).to match(/Usage:/)
    end
  end
end
