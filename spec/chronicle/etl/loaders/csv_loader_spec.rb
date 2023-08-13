require 'spec_helper'
require 'csv'

RSpec.describe Chronicle::ETL::CSVLoader do
  # TODO: consolidate this with other specs
  let(:record) do
    Chronicle::Schema::Activity.new(
      provider: 'foo',
      verb: 'tested',
      actor: Chronicle::Schema::Entity.new(
        represent: 'identity',
        provider: 'bar'
      )
    )
  end

  context "when destination is stdout" do
    it 'can output a CSV' do
      l = Chronicle::ETL::CSVLoader.new

      l.load(record)
      l.load(record)

      lines = capture do
        l.finish
      end.first.split("\n")

      expect(lines.count).to eql(3)
    end
  end

  context "when destination is a file" do
    it "writes json to a file" do
      FakeFS.with_fresh do
        l = Chronicle::ETL::CSVLoader.new(output: 'test.csv')
        l.load(record)
        l.load(record)
        l.finish

        csv = CSV.parse(File.read('test.csv'))
        expect(csv.count).to eql(3)
      end
    end
  end
end
