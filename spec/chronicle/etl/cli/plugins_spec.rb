require 'spec_helper'

RSpec.describe Chronicle::ETL::CLI::Plugins do
  describe "#list" do
    it "shows installed plugins" do
      stdout, = invoke_cli(%w[plugins:list])
      expect(stdout.split("\n").first).to match(/Installed plugins/)
    end
  end

  describe "#uninstall" do
    context "for a plugin that doesn't exist" do
      it "will exit with an error" do
        expect do 
          invoke_cli(%w[plugins:uninstall foobar123], false)
        end.to raise_error(SystemExit) { |exit| expect(exit.status).to be(1) }
      end

      it "will show an error message" do
        _, stderr = invoke_cli(%w[plugins:uninstall foobar123])
        expect(stderr.split("\n").map(&:uncolorize).first).to match(/could not be uninstalled/)
      end
    end
  end
end
