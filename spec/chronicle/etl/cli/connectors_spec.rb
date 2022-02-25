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

  describe "#show" do
    context "with a a bad phase type" do
      it "will show an error message" do
        output = invoke_cli(%w[connectors:show transmorpher foo]).split("\n").map(&:uncolorize)
        expect(output.first).to match(/must be one of/)
      end
    end

    context "for a connector that does not exist" do
      it "will show an error" do
        output = invoke_cli(%w[connectors:show extractor unknown]).split("\n").map(&:uncolorize)
        expect(output.first).to match(/Could not find/)
      end
    end

    context "for a connector that exists" do
      it "can show basic information a connector" do
        output = invoke_cli(%w[connectors:show extractor csv]).split("\n").map(&:uncolorize)
        expect(output.first).to eql("Chronicle::ETL::CSVExtractor")
      end
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
