# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chronicle::ETL::Secrets do
  include_context "mocked config directory"

  describe "#all" do
    it "can retrieve all secrets" do
      expect(described_class.all.keys).to contain_exactly(:'provider-one', :'provider-two')
    end
  end

  describe "#set" do
    it "can set a secret" do
      described_class.set("new-namespace", "key", "value")
      value = described_class.read("new-namespace")[:key]
      expect(value).to eql("value")
    end
  end

  describe "#unset" do
    it "can unset a secret" do
      described_class.set("new-namespace", "key", "value")
      value = described_class.read("new-namespace")[:key]
      expect(value).to eql("value")

      described_class.unset("new-namespace", "key")
      value = described_class.read("new-namespace")[:key]
      expect(value).to eql(nil)
    end
  end

  describe "#available_secrets" do
    it "can list all secrets" do
      expect(described_class.available_secrets).to contain_exactly('provider-one', 'provider-two')
    end
  end
end
