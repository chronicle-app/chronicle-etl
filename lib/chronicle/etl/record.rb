# frozen_string_literal: true

module Chronicle::ETL
  class Record
    attr_accessor :data, :extraction

    def initialize(data: {}, extraction: nil)
      @data = data
      @extraction = extraction
    end
  end
end
