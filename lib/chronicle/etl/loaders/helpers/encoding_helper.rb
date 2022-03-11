require 'pathname'

module Chronicle
  module ETL
    module Loaders
      module Helpers
        module EncodingHelper
          # Mostly useful for handling loading with binary data from a raw extraction
          def force_utf8(value)
            return value unless value.is_a?(String)

            value.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
          end
        end
      end
    end
  end
end
