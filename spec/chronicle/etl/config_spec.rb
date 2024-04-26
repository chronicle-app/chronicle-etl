require 'spec_helper'

RSpec.describe Chronicle::ETL::Config do
  include_context 'mocked config directory'

  # TODO: remove this after proper tests written for Config
  it 'can set a custom homedir' do
    data = {}
    data[Time.now.to_i] = Time.now
    Chronicle::ETL::Config.write('jobs', 'foo', data)
    expect(Chronicle::ETL::Config.available_jobs).to contain_exactly('command', 'foo')
  end

  describe '#available_jobs' do
    it 'can list jobs' do
      expect(Chronicle::ETL::Config.available_jobs).to eq(['command'])
    end
  end
end
