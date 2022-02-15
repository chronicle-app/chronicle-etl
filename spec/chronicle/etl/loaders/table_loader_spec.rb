require 'spec_helper'

RSpec.describe Chronicle::ETL::TableLoader do
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

  it 'can output a table' do
    l = Chronicle::ETL::TableLoader.new

    l.load(record)
    lines = capture(:stdout) do 
      l.finish
    end.split("\n")

    # header + record
    expect(lines.count).to eql(2)
  end
end
