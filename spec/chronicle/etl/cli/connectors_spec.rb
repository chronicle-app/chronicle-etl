require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Connectors do
  describe "#list" do
    it "lists installed connectors" do
      expected_klasses = Chronicle::ETL::Registry.connectors.map(&:klass_name)

      outputted_klasses = invoke_cli(%w[connectors:list])
        .split("\n")  # ignore the ascii table header 
        .drop(1)      # parse out the connector classes
        .map { |k| k.match(/(Chronicle::(\w+)::(\w+))/)&.captures&.first }
        .compact

      expect(expected_klasses).to match_array(outputted_klasses)
    end
  end

  describe "#help" do
    it "outputs help for connectors" do
      expect(invoke_cli(%w[connectors help])).to match(/COMMANDS/)
    end

    it "outputs help for a connector subcommand" do
      expect(invoke_cli(%w[connectors help list])).to match(/Usage:/)
    end
  end
end
