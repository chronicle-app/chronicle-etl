require 'forwardable'

module Chronicle
  module ETL
    # A record of what happened in the running of a job. We're interested in
    # tracking when it ran, if it was successful, and what the latest record
    # we found is (to use as a cursor for the next time)
    class JobLog
      extend Forwardable

      attr_accessor :job,
                    :job_id,
                    :last_id,
                    :highest_timestamp,
                    :num_records_processed,
                    :started_at,
                    :finished_at,
                    :success

      def_delegators :@job, :save_log?

      # Create a new JobLog for a given Job
      def initialize
        @num_records_processed = 0
        @success = false
        yield self if block_given?
      end

      # Log the result of a single transformation in a job
      # @param transformer [Chronicle::ETL::Tranformer] The transformer that ran
      def log_transformation(transformer)
        @last_id = transformer.id if transformer.id

        # Save the highest timestamp that we've encountered so far
        @highest_timestamp = [transformer.timestamp, @highest_timestamp].compact.max if transformer.timestamp

        # TODO: a transformer might yield nil. We might also want certain transformers to explode
        # records into multiple new ones. Therefore, this this variable will need more subtle behaviour
        @num_records_processed += 1
      end

      # Indicate that a job has started
      def start
        @started_at = Time.now
      end

      # Indicate that a job has finished
      def finish
        @finished_at = Time.now
        @success = true
      end

      def error
        @finished_at = Time.now
      end

      def job= job
        @job = job
        @job_id = job.id
      end

      def duration
        return unless @finished_at && @started_at

        @finished_at - @started_at
      end

      # Take a JobLog's instance variables and turn them into a hash representation
      def serialize
        {
          job_id: @job_id,
          last_id: @last_id,
          highest_timestamp: @highest_timestamp,
          num_records_processed: @num_records_processed,
          started_at: @started_at,
          finished_at: @finished_at,
          success: @success
        }
      end

      private

      # Create a new JobLog and set its instance variables from a serialized hash
      def self.build_from_serialized attrs
        attrs.delete(:id)
        new do |job_log|
          attrs.each do |key, value|
            setter = "#{key.to_s}=".to_sym
            job_log.send(setter, value)
          end
        end
      end
    end
  end
end
