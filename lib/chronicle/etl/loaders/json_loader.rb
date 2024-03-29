# frozen_string_literal: true

require 'tempfile'

module Chronicle
  module ETL
    class JSONLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::StdoutHelper

      register_connector do |r|
        r.identifier = :json
        r.description = 'json'
      end

      setting :serializer
      setting :output

      # If true, one JSON record per line. If false, output a single json
      # object with an array of records
      setting :line_separated, default: true, type: :boolean

      def initialize(*args)
        super
        @first_line = true
      end

      def start
        @output_file =
          if output_to_stdout?
            create_stdout_temp_file
          else
            File.open(@config.output, "w+")
          end

        @output_file.puts("[\n") unless @config.line_separated
      end

      def load(record)
        # serialized = serializer.serialize(record)
        serialized = record.to_h

        # When dealing with raw data, we can get improperly encoded strings
        # (eg from sqlite database columns). We force conversion to UTF-8
        # before converting into JSON
        encoded = serialized.transform_values do |value|
          next value unless value.is_a?(String)

          force_utf8(value)
        end

        line = encoded.to_json
        # For line-separated output, we just put json + newline
        if @config.line_separated
          line = "#{line}\n"
        # Otherwise, we add a comma and newline and then add record to the
        # array we created in #start (unless it's the first line).
        else
          line = ",\n#{line}" unless @first_line
        end

        @output_file.write(line)

        @first_line = false
      end

      def finish
        # Close the array unless we're doing line-separated JSON
        @output_file.puts("\n]") unless @config.line_separated

        write_to_stdout_from_temp_file(@output_file) if output_to_stdout?

        @output_file.close
      end

      private

      # TODO: implement this
      def serializer
        require 'chronicle/serialization'
        @config.serializer || Chronicle::Serialization::HashSerializer
      end
    end
  end
end
