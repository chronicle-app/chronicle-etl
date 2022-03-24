require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Secrets do
  include_context "mocked config directory"

  describe "chronicle-etl secrets:list" do
    it "can list available secrets" do
      args = ['secrets:list']
      output, = invoke_cli(args)

      all_secrets = Chronicle::ETL::Secrets.all.values.map(&:values).flatten

      expect(output.split("\n").count).to eql(all_secrets.count + 2)
    end
  end

  describe "chronicle-etl secrets:set" do
    it "can set a secret" do
      args = %w[secrets:set foo key value]
      invoke_cli(args)

      expect(Chronicle::ETL::Secrets.read('foo')[:key]).to eql("value")
    end

    context "when value not provided" do
      include_context "mocked stdin"

      it "can set a secret with stdin" do
        load_stdin("baz")
        args = %w[secrets:set foo key]
        invoke_cli(args)

        expect(Chronicle::ETL::Secrets.read('foo')[:key]).to eql("baz")
      end
    end
  end

  describe "chronicle-etl secrets:unset" do
    it "can unset a secret" do
      args = %w[secrets:set foo key value]
      invoke_cli(args)
      expect(Chronicle::ETL::Secrets.read('foo')[:key]).to eql("value")

      args = %w[secrets:unset foo key]
      invoke_cli(args)
      expect(Chronicle::ETL::Secrets.read('foo')[:key]).to be_nil
    end
  end
end
