require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Authorizations do
  describe '#new' do
    context 'with an available plugin' do
      before do
        %w[foo empty error].each do |plugin|
          path = File.expand_path(File.join(RSPEC_ROOT, "support/mock_plugins/chronicle-#{plugin}"))
          $LOAD_PATH.unshift(path)
          Chronicle::ETL::Registry::Plugins.register_standalone(name: plugin)
        end
      end

      it 'can authorize' do
        FakeFS.with_fresh do
          _, stderr = invoke_cli(%w[authorizations:new foo])

          expect(Chronicle::ETL::Secrets.read('foo')).to eql({ token: 'abc' })
        end
      end

      it 'can print authorization results to stdout' do
        FakeFS.with_fresh do
          stdout, = invoke_cli(%w[authorizations:new foo --print])

          expect(stdout).to match(/abc/)
        end
      end
    end

    context "for credentials specified that don't exist" do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[authorizations:new foo --credentials fake123], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error message' do
        _, stderr = invoke_cli(%w[authorizations:new foo --credentials fake123])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/name does not exist/)
      end
    end

    context "for a plugin that can't be loaded" do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[authorizations:new error], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error message' do
        _, stderr = invoke_cli(%w[authorizations:new error])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/Could not load/)
      end
    end

    context "for a plugin that doesn't have an authorizer" do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[authorizations:new empty], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error message' do
        _, stderr = invoke_cli(%w[authorizations:new empty])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/No authorizer available/)
      end
    end

    context "for a plugin that's not installed" do
      it 'will exit with an error' do
        expect do
          invoke_cli(%w[authorizations:new foobar123], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it 'will show an error message' do
        _, stderr = invoke_cli(%w[authorizations:new foobar123])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/is not installed/)
      end
    end
  end
end
