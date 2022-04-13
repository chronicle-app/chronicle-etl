require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Authorizations do
  describe "#authorize" do
    context "with an available plugin" do
      before do
        path = File.expand_path(File.join(RSPEC_ROOT, 'support/mock_plugins/chronicle-foo'))
        $LOAD_PATH.unshift(path)
        Chronicle::ETL::Registry::PluginRegistry.register_standalone('foo')
      end

      it "can authorize" do
        FakeFS.with_fresh do
          _, stderr = invoke_cli(%w[authorizations:authorize foo])

          expect(Chronicle::ETL::Secrets.read('foo')).to eql({token: "abc"})
        end
      end

      it "can print authorization results to stdout" do
        FakeFS.with_fresh do
          stdout, _ = invoke_cli(%w[authorizations:authorize foo --print])

          expect(stdout).to match(/abc/)
        end
      end
    end

    context "for a plugin that's not installed" do
      it "will exit with an error" do
        expect do 
          invoke_cli(%w[authorizations:authorize foobar123], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it "will show an error message" do
        _, stderr = invoke_cli(%w[authorizations:authorize foobar123])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/is not installed/)
      end
    end
  end
end
