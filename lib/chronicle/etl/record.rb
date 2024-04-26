# frozen_string_literal: true

# TODO: move this into chronicle-core after figuring out what to do about data vs properties
module Chronicle
  module ETL
    class Record
      attr_accessor :data, :extraction

      def initialize(data: {}, extraction: nil)
        @data = data
        @extraction = extraction
      end
    end
  end
end
