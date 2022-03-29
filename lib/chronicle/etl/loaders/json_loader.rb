require 'tempfile'

module Chronicle
  module ETL
    class JSONLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::StdoutHelper

      register_connector do |r|
        r.description = 'json'
      end

      setting :serializer
      setting :output

      def start
        @output_file =
          if output_to_stdout?
            create_stdout_temp_file
          else
            File.open(@config.output, "w+")
          end
      end

      def load(record)
        serialized = serializer.serialize(record)

        # When dealing with raw data, we can get improperly encoded strings
        # (eg from sqlite database columns). We force conversion to UTF-8
        # before converting into JSON
        encoded = serialized.transform_values do |value|
          next value unless value.is_a?(String)

          force_utf8(value)
        end

        @output_file.puts(encoded.to_json)
      end

      def finish
        write_to_stdout_from_temp_file(@output_file) if output_to_stdout?

        @output_file.close
      end

      private

      def serializer
        @config.serializer || Chronicle::ETL::RawSerializer
      end
    end
  end
end
