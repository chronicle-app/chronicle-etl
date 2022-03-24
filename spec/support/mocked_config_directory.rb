require 'fakefs/spec_helpers'

RSpec.shared_context "mocked config directory" do
  around(:each) do |example|
    include FakeFS::SpecHelpers

    FakeFS.with_fresh do
      home = File.expand_path(File.join(RSPEC_ROOT, 'support/mock_homedir'))
      FakeFS::FileSystem.clone(home)

      Chronicle::ETL::Config.xdg_environment = { "HOME" => home }

      example.run

      Chronicle::ETL::Config.xdg_environment = nil
    end
  end
end
