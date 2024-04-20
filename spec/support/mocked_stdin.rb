require 'stringio'

RSpec.shared_context 'mocked stdin' do
  let(:fake_stdin) { StringIO.new }

  def load_stdin(input)
    fake_stdin.puts(input)
    fake_stdin.rewind
  end

  around(:each) do |example|
    $stdin = fake_stdin
    example.run
  ensure
    $stdin = STDIN
  end
end
