require 'spec_helper'

RSpec.describe Chronicle::ETL::TableLoader do
  let(:record) do
    {
      provider: 'foo',
      verb: 'tested',
      actor: {
        represent: 'identity',
        provider: 'bar'
      }
    }
  end

  it 'can output a table' do
    l = Chronicle::ETL::TableLoader.new

    l.load(record)
    lines = capture do
      l.finish
    end.first.split("\n")

    # header + record
    expect(lines.count).to eql(2)
  end
end
