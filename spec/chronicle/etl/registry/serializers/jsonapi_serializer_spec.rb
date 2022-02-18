require 'spec_helper'

RSpec.describe Chronicle::ETL::JSONAPISerializer do
  let(:record) do
    Chronicle::ETL::Models::Activity.new(
      provider: 'foo',
      verb: 'tested',
      actor: Chronicle::ETL::Models::Entity.new(
        represent: 'identity',
        provider: 'bar'
      )
    )
  end

  it "can build" do
    expected = {
      type: "activities",
      lids: [],
      attributes: { provider: "foo", metadata: {}, verb: "tested" },
      relationships: { actor: { data: { type: "entities", lids: [], attributes: { provider: "bar", metadata: {} }, relationships: {}, meta: { dedupe_on: [] } } } },
      meta: { dedupe_on: [] }
    }
    expect(Chronicle::ETL::JSONAPISerializer.serialize(record).to_json).to eql(expected.to_json)
  end
end
