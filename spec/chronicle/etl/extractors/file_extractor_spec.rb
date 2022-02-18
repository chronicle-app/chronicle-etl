require 'spec_helper'

RSpec.describe Chronicle::ETL::FileExtractor do
  let(:filename) { 'spec/support/sample_data/two-records.csv' }
  let(:directory) { 'spec/support/sample_data/directories/simple' }

  # TODO: specs for single files
  # TODO: specs for glob pattern
  # TODO: specs for testing results of actual filenames

  context "for a simple directory" do
    describe "#results_count" do
      it "can extract from a CSV file" do
        e = Chronicle::ETL::FileExtractor.new(filename: directory, dir_glob_pattern: '**/*')
        expect(e.results_count).to eql(2)
      end
    end

    describe "#extract" do
      it "can yield filenames in the directory" do
        e = Chronicle::ETL::FileExtractor.new(filename: directory, dir_glob_pattern: '**/*')
        expect { |b| e.extract(&b) } .to yield_successive_args(Chronicle::ETL::Extraction, Chronicle::ETL::Extraction)
      end
    end
  end
end
