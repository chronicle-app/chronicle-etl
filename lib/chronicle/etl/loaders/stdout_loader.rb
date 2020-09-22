module Chronicle
  module ETL
    class StdoutLoader < Chronicle::ETL::Loader
      def load(record)
        puts record.to_h
      end
    end
  end
end
