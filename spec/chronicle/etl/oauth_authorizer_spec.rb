require 'spec_helper'

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:developer] = {
  token: 'abc'
}
# Make sure AuthorizationServer knows we're in test mode
ENV['APP_ENV'] = 'test'

# Prevent Launchy from attempt to open windows in oauth_authorizer.rb
ENV['LAUNCHY_DRY_RUN'] = 'true'

RSpec.describe Chronicle::ETL::OauthAuthorizer do
  let(:port) { 5678 }
  let(:authorizer) do
    Class.new(Chronicle::ETL::OauthAuthorizer) do
      provider :foo
      omniauth_strategy :developer
      scope 'email'
      pluck_secrets({ token: [:token]})
    end
  end

  before do
    stub_const("FooAuthorizer", authorizer)
  end

  it "returs an authorization after oauth flow completed" do
    a = authorizer.new(port: port)
    thread = Thread.new do
      wait_until do
        booted?
      end
      fetch("http://localhost:#{port}/auth/developer/")
    end

    result = suppress_output do
      a.authorize!
    end
    thread.join
    expect(result).to eql({ token: 'abc' })
  end

  it "raises an exception if flow aborts early" do
    # TODO: implement this somehow
    # send signal to sinatra?
  end

  def booted?
    fetch("http://localhost:#{port}/")
    true
  rescue Errno::ECONNREFUSED, Errno::EBADF
    false
  end

  # TODO: use library? put in SpecHelpers?
  def fetch(uri, limit = 10)
    response = Net::HTTP.get_response(URI(uri))
    fetch(response['location'], limit - 1) if response == Net::HTTPRedirection || response.code == "302"
  end
end
