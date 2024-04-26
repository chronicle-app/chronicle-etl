module Chronicle
  module ETL
    module SpecHelpers
      # https://stackoverflow.com/questions/19388474/how-can-i-use-sinatra-to-simulate-a-remote-server-in-rspec-vcr
      def wait_until(timeout = 1)
        start_time = Time.now

        loop do
          return if yield
          raise TimeoutError if (Time.now - start_time) > timeout

          sleep(0.1)
        end
      end
    end
  end
end
