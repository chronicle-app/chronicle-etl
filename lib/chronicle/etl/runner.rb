# frozen_string_literal: true

require 'colorize'
require 'chronic_duration'
require 'tty-spinner'

module Chronicle
  module ETL
    class Runner
      def initialize(job)
        @job = job
        @job_logger = Chronicle::ETL::JobLogger.new(@job)
      end

      def run!
        begin_job
        validate_job
        instantiate_connectors
        prepare_job
        prepare_ui
        run_extraction
      rescue Chronicle::ETL::ExtractionError => e
        @job_logger&.error
        raise(Chronicle::ETL::RunnerError, "Extraction failed. #{e.message}")
      rescue Interrupt
        @job_logger&.error
        raise(Chronicle::ETL::RunInterruptedError, 'Job interrupted.')
      # rescue StandardError => e
      #   # Just throwing this in here until we have better exception handling in
      #   # loaders, etc
      #   @job_logger&.error
      #   raise(Chronicle::ETL::RunnerError, "Error running job. #{e.message}")
      ensure
        finish_job
      end

      private

      def begin_job
        Chronicle::ETL::Logger.info(tty_log_job_initialize)
        @initialization_spinner = TTY::Spinner.new(':spinner :title', format: :dots_2)
      end

      def validate_job
        @initialization_spinner.update(title: 'Validating job')
        @job.job_definition.validate!
      end

      def instantiate_connectors
        @initialization_spinner.update(title: 'Initializing connectors')
        @extractor = @job.instantiate_extractor
        @transformers = @job.instantiate_transformers
        @loader = @job.instantiate_loader
      end

      def prepare_job
        @initialization_spinner.update(title: 'Preparing job')
        @job_logger.start
        @loader.start

        @initialization_spinner.update(title: 'Preparing extraction')
        @initialization_spinner.auto_spin
        @extractor.prepare
        @initialization_spinner.success("(#{'successful'.green})")
        Chronicle::ETL::Logger.info("\n")
      end

      def prepare_ui
        total = @extractor.results_count
        @progress_bar = Chronicle::ETL::Utils::ProgressBar.new(title: 'Running job', total: total)
        Chronicle::ETL::Logger.attach_to_ui(@progress_bar)
      end

      def run_extraction
        # Pattern based on Kiba's StreamingRunner
        # https://github.com/thbar/kiba/blob/master/lib/kiba/streaming_runner.rb
        stream = extractor_stream
        recurser = ->(s, t) { transform_stream(s, t) }
        @transformers.reduce(stream, &recurser).each do |record|
          Chronicle::ETL::Logger.debug(tty_log_transformation(record))
          @job_logger.log_transformation(record)
          @progress_bar.increment
          load_record(record)
        end

        @progress_bar.finish

        # This is typically a slow method (writing to stdout, writing a big file, etc)
        # TODO: consider adding a spinner?
        @loader.finish
        @job_logger.finish
      end

      # Initial steam of extracted data, wrapped in a Record class
      def extractor_stream
        Enumerator.new do |y|
          @extractor.extract do |extraction|
            record = Chronicle::ETL::Record.new(data: extraction.data, extraction: extraction)
            y << record
          end
        end
      end

      # For a given stream of records and a given transformer,
      # returns a new stream of transformed records and finally
      # calls the finish method on the transformer
      def transform_stream(stream, transformer)
        Enumerator.new do |y|
          stream.each do |record|
            transformer.call(record) do |transformed_record|
              y << transformed_record
            end
          end

          transformer.call_finish do |transformed_record|
            y << transformed_record
          end
        end
      end

      def load_record(record)
        @loader.load(record.data) unless @job.dry_run?
      end

      def finish_job
        @job_logger.save
        @progress_bar&.finish
        Chronicle::ETL::Logger.detach_from_ui
        Chronicle::ETL::Logger.info(tty_log_completion)
      end

      def tty_log_job_initialize
        output = 'Beginning job '
        output += "'#{@job.name}'".bold if @job.name
        output
      end

      def tty_log_transformation(record)
        output = '  ✓'.green
        output + " #{record}"
      end

      def tty_log_transformation_failure(exception, transformer)
        output = '  ✖'.red
        output + " Failed to transform #{transformer}. #{exception.message}"
      end

      def tty_log_completion
        status = @job_logger.success ? 'Success' : 'Failed'
        job_completion = @job_logger.success ? 'Completed' : 'Partially completed'
        output = "\n#{job_completion} job"
        output += " '#{@job.name}'".bold if @job.name
        output += " in #{ChronicDuration.output(@job_logger.duration)}" if @job_logger.duration
        output += "\n  Status:\t".light_black + status
        output += "\n  Completed:\t".light_black + @job_logger.job_log.num_records_processed.to_s
        if @job_logger.job_log.highest_timestamp
          output += "\n  Latest:\t".light_black + @job_logger.job_log.highest_timestamp.iso8601.to_s
        end
        output
      end
    end
  end
end
