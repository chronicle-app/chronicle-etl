require 'spec_helper'

RSpec.describe Chronicle::ETL::JSONExtractor do
  let(:json_filename) { 'spec/support/sample_data/sample.json' }
  let(:jsonl_filename) { 'spec/support/sample_data/sample.jsonl' }
  let(:invalid_filename) { 'spec/support/sample_data/test.csv' }

  describe '#results_count' do
    it 'can extract from a CSV file' do
      e = Chronicle::ETL::JSONExtractor.new(input: jsonl_filename)
      e.prepare
      expect(e.results_count).to eql(2)
    end
  end

  describe '#extract' do
    it 'can extract from a JSONL file' do
      e = Chronicle::ETL::JSONExtractor.new(input: jsonl_filename)
      e.prepare
      expect { |b| e.extract(&b) }.to yield_successive_args(Chronicle::ETL::Extraction, Chronicle::ETL::Extraction)
    end

    context 'for invalid json' do
      it 'will raise an exception' do
        e = Chronicle::ETL::JSONExtractor.new(input: invalid_filename)
        expect { e.prepare }.to raise_error(Chronicle::ETL::ExtractionError)
      end
    end
  end
end
