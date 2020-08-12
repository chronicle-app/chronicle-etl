module Chronicle
  module Etl
    class StdoutLoader < Chronicle::Etl::Loader
      def load(result)
        puts result.inspect
      end
    end
  end
end