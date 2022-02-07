require 'active_support/core_ext/object/blank'

module Chronicle
  module ETL
    module Utils
      # OCR for image files
      # TODO: add other strategies and document `macocr`
      module TextRecognition
        def self.recognize_in_image(filename:)
          `macocr "#{filename}" 2>/dev/null`.presence
        end
      end
    end
  end
end
