module Chronicle
  module ETL
    class StdoutLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'stdout'
      end

      def load(record)
        serializer = Chronicle::ETL::JSONAPISerializer.new(record)
        puts serializer.serializable_hash.to_json
      end
    end
  end
end
