module Chronicle
  module ETL
    # Abstract class representing an Transformer for an ETL job
    class Transformer
      extend Chronicle::ETL::Registry::SelfRegistering
      include Chronicle::ETL::Configurable

      # Construct a new instance of this transformer. Options are passed in from a Runner
      # == Parameters:
      # options::
      #   Options for configuring this Transformer
      def initialize(extraction, options = {})
        unless extraction.is_a?(Chronicle::ETL::Extraction)
          raise Chronicle::ETL::RunnerTypeError, "Extracted should be a Chronicle::ETL::Extraction"
        end

        @extraction = extraction
        apply_options(options)
      end

      # @abstract Subclass is expected to implement #transform
      # @!method transform
      #   The main entrypoint for transforming a record. Called by a Runner on each extracted record

      # The domain or provider-specific id of the record this transformer is working on.
      # It is useful for: 
      # - de-duping records that might exist in the loader's destination
      # - building a cursor so an extractor doesn't have to start from the beginning of a 
      #   a source 
      def id
        raise NotImplementedError
      end

      # The domain or provider-specific timestamp of the record this transformer is working on.
      # Used for building a cursor so an extractor doesn't have to start from the beginning of a
      # data source from the beginning.
      def timestamp
        raise NotImplementedError
      end

      # An optional, human-readable identifier for a transformation, intended for debugging or logging.
      # By default, it is just the id.
      def friendly_identifier
        id
      end

      def to_s
        ts = begin
          unknown = "???"
          timestamp&.iso8601 || unknown
        rescue TransformationError, NotImplementedError
          unknown
        end

        identifier = begin
          unknown = self.class.to_s
          friendly_identifier || "instance of #{self.class.to_s}"
        rescue TransformationError, NotImplementedError
          unknown
        end

        "[#{ts}] #{identifier}"
      end
    end
  end
end

require_relative 'null_transformer'
require_relative 'image_file_transformer'
