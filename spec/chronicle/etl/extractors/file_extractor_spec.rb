require 'spec_helper'

RSpec.describe Chronicle::ETL::FileExtractor do
  let(:filename) { 'spec/support/sample_data/two-records.csv' }
  let(:directory) { 'spec/support/sample_data/directories/simple' }

  context 'for a simple directory' do
    describe '#results_count' do
      it 'can extract from a CSV file' do
        e = Chronicle::ETL::FileExtractor.new(input: directory, dir_glob_pattern: '**/*')
        e.prepare
        expect(e.results_count).to eql(2)
      end
    end

    describe '#extract' do
      it 'can yield filenames in the directory' do
        results = run_extraction(Chronicle::ETL::FileExtractor, { input: directory, dir_glob_pattern: '**/*' })
        expect(results).to all(be_a(Chronicle::ETL::Extraction))
        expect(results.count).to eql(2)
      end
    end
  end

  context 'when passed in files' do
    it 'will yield file back' do
      results = run_extraction(Chronicle::ETL::FileExtractor, { input: [filename] })
      expect(results.count).to eql(1)
      expect(results.first.data).to eql(filename)
    end

    context 'when passed in two of the same files' do
      it 'will yield file once' do
        results = run_extraction(Chronicle::ETL::FileExtractor, { input: [filename, filename] })
        expect(results.count).to eql(1)
        expect(results.first.data).to eql(filename)
      end
    end
  end
end
