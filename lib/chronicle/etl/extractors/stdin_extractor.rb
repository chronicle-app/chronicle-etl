# frozen_string_literal: true

module Chronicle
  module ETL
    class StdinExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.identifier = :stdin
        r.description = 'stdin'
      end

      def extract
        $stdin.read.each_line do |line|
          data = { line: line.strip }
          yield Chronicle::ETL::Extraction.new(data: data)
        end
      end
    end
  end
end
