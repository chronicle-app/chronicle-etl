require 'marcel'
require 'base64'

module Chronicle
  module ETL
    module Utils
      # Utility methods for dealing with binary files
      module BinaryAttachments
        def self.filename_to_base64(filename:, mimetype: nil)
          mimetype = mimetype || guess_mimetype(filename: filename)

          "data:#{mimetype};base64,#{Base64.strict_encode64(File.read(filename))}"
        end

        def self.guess_mimetype(filename:)
          Marcel::MimeType.for(filename)
        end
      end
    end
  end
end
