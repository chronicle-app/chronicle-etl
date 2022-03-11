require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Main do
  describe "#version" do
    it "outputs correct version" do
      output, _ = invoke_cli(["version"])
      expect(output).to match("chronicle-etl #{Chronicle::ETL::VERSION}")
    end

    it "can be shown by calling cli with `--version`" do
      output, _ = invoke_cli(["--version"])
      expect(output).to match("chronicle-etl #{Chronicle::ETL::VERSION}")
    end
  end

  describe "#help" do
    it "outputs help menu" do
      output, _ = invoke_cli(["help"])
      expect(output).to match(/ALL COMMANDS/)
    end
  end
end
