module Chronicle
  module Etl
    module Loaders
      class StdoutLoader < Chronicle::Etl::Loaders::Loader
        def load(result)
          puts result.inspect
        end
      end
    end
  end
end