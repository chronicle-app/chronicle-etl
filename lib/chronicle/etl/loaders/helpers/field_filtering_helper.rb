require 'pathname'

module Chronicle
  module ETL
    module Loaders
      module Helpers
        module FieldFilteringHelper
          def filtered_headers(records)
            records_flattened = records.map(&:to_h_flattened)

            if @config.fields&.any?
              headers = Set.new
              @config.fields.each do |field|
                # select all array elements if no index is specified
                s = field.gsub(/\[\]/, '[\d+]')

                # escape underscores and brackets
                s = s.gsub(/[_\[\]]/, '\\\\\0')

                # build a regex that matches the field at the beginning or end of a string
                regex = "^(#{s}\\.|#{s}$)"

                headers += records_flattened.flat_map(&:keys).select { |key| key.match(regex) }
              end
            else
              # use all the keys of the flattened record hash
              headers = Set[*records_flattened.map(&:keys).flatten.map(&:to_s).uniq]
            end

            headers = headers.delete_if { |header| header.end_with?(*@config.fields_exclude) }
            headers = headers.first(@config.fields_limit) if @config.fields_limit

            raise(LoaderError, 'No fields selected') if headers.empty?

            headers.to_a.map(&:to_sym)
          end
        end
      end
    end
  end
end
