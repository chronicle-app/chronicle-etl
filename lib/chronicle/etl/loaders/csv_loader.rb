require 'csv'

module Chronicle
  module ETL
    class CSVLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'CSV'
      end

      setting :output, default: $stdout
      setting :headers, default: true

      def records
        @records ||= []
      end

      def load(record)
        records << record.to_h_flattened
      end

      def finish
        return unless records.any?

        csv_options = {}
        if @config.headers
          csv_options[:write_headers] = true
          csv_options[:headers] = records.first.keys
        end

        if @config.output.is_a?(IO)
          # This might seem like a duplication of the default value ($stdout)
          # but it's because rspec overwrites $stdout (in helper #capture) to
          # capture output.
          io = $stdout.dup
        else
          io = File.open(@config.output, "w+")
        end

        output = CSV.generate(**csv_options) do |csv|
          records.each do |record|
            csv << record.values.map { |value| force_utf8(value) }
          end
        end

        io.write(output)
        io.close
      end
    end
  end
end
