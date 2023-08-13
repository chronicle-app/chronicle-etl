require 'spec_helper'

RSpec.describe Chronicle::ETL::NullTransformer do
  let (:extraction) { Chronicle::ETL::Extraction.new(data: {foo: 'bar'}) }

  describe "#transform" do
    it "does nothing" do
      t = Chronicle::ETL::NullTransformer.new(extraction)
      expect(t.transform.foo).to eq('bar')
    end
  end
end
