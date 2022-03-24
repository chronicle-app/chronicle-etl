require 'spec_helper'

RSpec.describe Chronicle::ETL::Config do
  include_context "mocked config directory"

  it "can set a custom homedir" do
    data = {}
    data[Time.now.to_i] = Time.now
    Chronicle::ETL::Config.write("jobs", "foo", data)
    expect(Chronicle::ETL::Config.available_jobs).to contain_exactly("command", "foo")
  end

  it "foo" do
    expect(Chronicle::ETL::Config.available_jobs).to eq(['command'])
  end
end
