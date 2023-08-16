require 'spec_helper'

RSpec.describe Chronicle::ETL::Loaders::Helpers::FieldFilteringHelper do
  class ExampleClass < Chronicle::ETL::Loader
    include Chronicle::ETL::Loaders::Helpers::FieldFilteringHelper
  end

  let(:record) do
    Chronicle::Schema::Activity.new(
      provider: 'foo',
      verb: 'tested',
      actor: Chronicle::Schema::Entity.new(
        represents: 'identity',
        provider: 'bar'
      )
    )
  end

  describe '#filtered_headers' do
    it 'returns expected result' do
      l = ExampleClass.new(fields: ['provider'])
      expect(l.filtered_headers([record, record])).to eq([:provider])
    end

    it 'can return nested object' do
      l = ExampleClass.new(fields: ['actor'])
      expect(l.filtered_headers([record]))
        .to eq([:'actor.represents', :'actor.provider'])
    end

    it 'raises an error if no valid fields selected' do
      l = ExampleClass.new(fields: ['foo'])
      expect { l.filtered_headers([record]) }
        .to raise_error(Chronicle::ETL::LoaderError)
    end

    it 'limits the number of fields returned if fields_limit used' do
      l = ExampleClass.new(fields: ['actor.represents', 'actor.provider'], fields_limit: 1)
      expect(l.filtered_headers([record])).to eq([:'actor.represents'])
    end

    it 'can filter out unwanted fields' do
      l = ExampleClass.new(fields: ['actor'], fields_exclude: ['actor.provider'])
      expect(l.filtered_headers([record])).to eq([:'actor.represents'])
    end
  end
end
