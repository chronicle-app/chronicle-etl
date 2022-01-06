module Chronicle
  module ETL
    class StdoutLoader < Chronicle::ETL::Loader
      DESCRIPTION = 'stdout'

      def load(record)
        serializer = Chronicle::ETL::JSONAPISerializer.new(record)
        puts serializer.serializable_hash.to_json
      end
    end
  end
end
