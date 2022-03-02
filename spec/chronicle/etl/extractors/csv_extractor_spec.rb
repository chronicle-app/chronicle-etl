require 'spec_helper'

RSpec.describe Chronicle::ETL::CSVExtractor do
  let(:filename) { 'spec/support/sample_data/two-records.csv' }

  describe "#results_count" do
    it "can extract from a CSV file" do
      e = Chronicle::ETL::CSVExtractor.new(input: filename)
      e.prepare
      expect(e.results_count).to eql(2)
    end
  end

  describe "#extract" do
    it "can extract from a CSV file" do
      e = Chronicle::ETL::CSVExtractor.new(input: filename)
      e.prepare
      expect { |b| e.extract(&b) } .to yield_successive_args(Chronicle::ETL::Extraction, Chronicle::ETL::Extraction)
    end
  end
end
