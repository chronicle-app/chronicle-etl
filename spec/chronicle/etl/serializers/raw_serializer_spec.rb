require 'spec_helper'

RSpec.describe Chronicle::ETL::RawSerializer do
  let(:record_raw) do
    Chronicle::Schema::Raw.new({ foo: 'bar', num: 4 })
  end

  it "outputs the raw fields of a RawModel" do
    expect(Chronicle::ETL::RawSerializer.serialize(record_raw)).to eql({foo: 'bar', num: 4})
  end
end
