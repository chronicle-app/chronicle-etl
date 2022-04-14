module Chronicle
  module ETL
    module SpecHelpers
      # Capture stdout/stderr in a block
      # Adapted from minitest
      # https://github.com/seattlerb/minitest/blob/7d2134a1d386a068f1c7705889c7764a47413861/lib/minitest/assertions.rb#L514
      def capture
        orig_stdout = $stdout
        orig_stderr = $stderr

        captured_stdout = StringIO.new
        captured_stderr = StringIO.new

        $stdout = captured_stdout
        $stderr = captured_stderr

        yield

        [captured_stdout.string, captured_stderr.string]
      ensure
        $stdout = orig_stdout
        $stderr = orig_stderr
      end

      # Quick and dirty method to run a block with suppressed stdout/stderr
      # TODO: refactor this to share code with above
      def suppress_output
        orig_stdout = $stdout
        orig_stderr = $stderr

        captured_stdout = StringIO.new
        captured_stderr = StringIO.new

        $stdout = captured_stdout
        $stderr = captured_stderr

        yield
      ensure
        $stdout = orig_stdout
        $stderr = orig_stderr
      end
    end
  end
end
