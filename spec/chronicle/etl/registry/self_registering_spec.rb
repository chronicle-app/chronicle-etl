require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Connectors do
  describe "#register_connector" do
    it "can register a new class" do
      expect do
        class TestExtractor < Chronicle::ETL::Extractor
          register_connector do |r|
            r.description = 'foobar'
          end
        end
      end.to change { Chronicle::ETL::Registry::Connectors.connectors.count }.by(1)

      expect(Chronicle::ETL::Registry::Connectors.connectors.map(&:description))
        .to include('foobar')
    end
  end
end
