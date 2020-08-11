require 'csv'

module Chronicle
  module Etl
    module Loaders
      class CsvLoader < Chronicle::Etl::Loaders::Loader
        def initialize(options={})
          super(options)
          @rows = []
        end

        def load(result)
          if (result.values)
            @rows << result.values
          else
            @rows << result
          end
        end

        def finish
          z = $stdout
          CSV(z) do |csv|
            @rows.each do |row|
              csv << row
            end
          end
        end
      end
    end
  end
end
