module Chronicle
  module ETL
    class JSONLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'json'
      end

      setting :serializer
      setting :output, default: $stdout

      def start
        if @config.output == $stdout
          @output = @config.output
        else
          @output = File.open(@config.output, "w")
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
        @output.puts encoded.to_json
      end

      def finish
        @output.close
      end

      private

      def serializer
        @config.serializer || Chronicle::ETL::RawSerializer
      end
    end
  end
end
