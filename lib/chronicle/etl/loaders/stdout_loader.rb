module Chronicle
  module ETL
    class StdoutLoader < Chronicle::ETL::Loader
      def load(result)
        puts result.inspect
      end
    end
  end
end