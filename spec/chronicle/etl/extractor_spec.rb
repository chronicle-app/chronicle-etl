require 'spec_helper'

RSpec.describe Chronicle::ETL::Extractor do
  describe "#extract" do
    it "raises an exception by default" do
      e = Chronicle::ETL::Extractor.new
      expect { e.extract } .to raise_error(NotImplementedError)
    end
  end
end
