require 'spec_helper'
require 'fakefs/safe'

RSpec.describe Chronicle::ETL::JSONLoader do
  let(:record) do
    { foo: 'bar' }
  end

  context 'when using stdout as destination' do
    it 'can output JSON from a Raw model' do
      l = Chronicle::ETL::JSONLoader.new

      output, = capture do
        l.start
        l.load(record)
        l.load(record)
        l.finish
      end

      lines = output.split("\n")
      expect(lines.count).to eql(2)
      expect(JSON.parse(lines.first)).to include({ 'foo' => 'bar' })
    end
  end

  context 'when using a file as destination' do
    it 'writes json to a file' do
      FakeFS.with_fresh do
        l = Chronicle::ETL::JSONLoader.new(output: 'output.jsonl')
        l.start
        l.load(record)
        l.load(record)
        l.finish

        contents = File.read('output.jsonl').split("\n")
        expect(JSON.parse(contents.first)).to include({ 'foo' => 'bar' })
      end
    end
  end
end
