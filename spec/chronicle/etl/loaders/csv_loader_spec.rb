require 'spec_helper'

RSpec.describe Chronicle::ETL::CSVLoader do
  # TODO: consolidate this with other specs
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

  it 'can output a CSV' do
    l = Chronicle::ETL::CSVLoader.new

    l.load(record)
    l.load(record)

    lines = capture do 
      l.finish
    end.first.split("\n")

    expect(lines.count).to eql(2)

    # TODO: more rigorous test
  end
end
