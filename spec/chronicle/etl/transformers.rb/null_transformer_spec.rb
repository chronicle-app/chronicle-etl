require 'spec_helper'

RSpec.describe Chronicle::ETL::NullTransformer do
  let(:record) { Chronicle::ETL::Record.new(data: { foo: 'bar' }) }

  describe '#transform' do
    it 'does nothing' do
      Chronicle::ETL::NullTransformer.new.transform(record) do |result|
        expect(result).to eq(foo: 'bar')
      end
    end
  end
end
