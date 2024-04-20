# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chronicle::ETL::Runner do
  before(:all) do
    Chronicle::ETL::Logger.log_level = Chronicle::ETL::Logger::FATAL
  end

  describe '#run!' do
    it 'runs' do
      filename = 'spec/support/sample_data/test.csv'

      # rows in sample CSV file (excluding header)
      file_record_count = File.read(filename).each_line.count - 1

      definition = Chronicle::ETL::JobDefinition.new
      definition.add_config(
        {
          extractor: {
            name: 'csv',
            options: {
              input: filename
            }
          },
          transformers: [
            {
              name: 'multiply',
              options: {
                n: 2
              }
            },
            {
              name: 'multiply',
              options: {
                n: 2
              }
            },
            {
              name: 'sort',
              options: {
                key: 'id',
                direction: 'desc'
              }
            }
          ],
          loader: {
            name: 'json'
          }
        }
      )

      job = Chronicle::ETL::Job.new(definition)

      r = Chronicle::ETL::Runner.new(job)

      output, = capture do
        r.run!
      end

      expect(output.split("\n").count).to eql(file_record_count * 4)
    end
  end
end
