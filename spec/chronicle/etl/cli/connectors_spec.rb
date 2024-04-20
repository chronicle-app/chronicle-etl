require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Connectors do
  describe '#list' do
    it 'lists installed connectors' do
      expected_klasses = Chronicle::ETL::Registry::Connectors.connectors.map(&:klass_name)

      stdout, = invoke_cli(%w[connectors:list])
      outputted_klasses = stdout
        .split("\n")  # ignore the ascii table header
        .drop(1)      # parse out the connector classes
        .map { |k| k.match(/(Chronicle::(\w+)::(\w+))/)&.captures&.first }
        .compact

      expect(expected_klasses).to match_array(outputted_klasses)
    end
  end

  describe '#show' do
    context 'with a a bad phase type' do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[connectors:show transmorpher foo], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error message' do
        _, stderr = invoke_cli(%w[connectors:show transmorpher foo])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/must be one of/)
      end
    end

    context 'for a connector that does not exist' do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[connectors:show extractor foo], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error' do
        _, stderr = invoke_cli(%w[connectors:show extractor unknown])
        # puts stderr
        expect(stderr).to match(/Could not find/)
      end
    end

    context 'for a connector that exists' do
      it 'can show basic information a connector' do
        output = invoke_cli(%w[connectors:show extractor csv]).first.split("\n").map(&:uncolorize)
        expect(output.first).to eql('Chronicle::ETL::CSVExtractor')
      end
    end
  end

  describe '#help' do
    it 'outputs help for connectors' do
      expect(invoke_cli(%w[connectors help]).first).to match(/COMMANDS/)
    end

    it 'outputs help for a connector subcommand' do
      expect(invoke_cli(%w[connectors help list]).first).to match(/Usage:/)
    end
  end
end
