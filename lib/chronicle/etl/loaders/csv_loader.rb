require 'csv'

module Chronicle
  module ETL
    class CSVLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'CSV'
      end

      def initialize(options={})
        super(options)
        @rows = []
      end

      def load(record)
        @rows << record.to_h_flattened.values
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
