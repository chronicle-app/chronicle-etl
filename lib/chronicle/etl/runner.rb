require 'colorize'
require 'chronic_duration'

class Chronicle::ETL::Runner
  def initialize(job)
    @job = job
    @job_logger = Chronicle::ETL::JobLogger.new(@job)
  end

  def run!
    extractor = @job.instantiate_extractor
    loader = @job.instantiate_loader

    @job_logger.start
    loader.start

    total = extractor.results_count
    @progress_bar = Chronicle::ETL::Utils::ProgressBar.new(title: 'Running job', total: total)
    Chronicle::ETL::Logger.attach_to_progress_bar(@progress_bar)

    Chronicle::ETL::Logger.info(tty_log_job_start)
    extractor.extract do |extraction|
      unless extraction.is_a?(Chronicle::ETL::Extraction)
        raise Chronicle::ETL::RunnerTypeError, "Extracted should be a Chronicle::ETL::Extraction"
      end

      transformer = @job.instantiate_transformer(extraction)
      record = transformer.transform

      unless record.is_a?(Chronicle::ETL::Models::Base)
        raise Chronicle::ETL::RunnerTypeError, "Transformed data should be a type of Chronicle::ETL::Models"
      end

      Chronicle::ETL::Logger.info(tty_log_transformation(transformer))
      @job_logger.log_transformation(transformer)

      loader.load(record) unless @job.dry_run?
    rescue Chronicle::ETL::TransformationError => e
      Chronicle::ETL::Logger.error(tty_log_transformation_failure(e))
    ensure
      @progress_bar.increment
    end

    @progress_bar.finish
    loader.finish
    @job_logger.finish
  rescue Interrupt
    Chronicle::ETL::Logger.error("\n#{'Job interrupted'.red}")
    @job_logger.error
  rescue StandardError => e
    raise e
  ensure
    @job_logger.save
    @progress_bar.finish
    Chronicle::ETL::Logger.detach_from_progress_bar
    Chronicle::ETL::Logger.info(tty_log_completion)
  end

  private

  def tty_log_job_start
    output = "Beginning job "
    output += "'#{@job.name}'".bold if @job.name
    output
  end

  def tty_log_transformation transformer
    output = "  ✓".green
    output += " #{transformer}"
  end

  def tty_log_transformation_failure exception
    output = "  ✖".red
    output += " Failed to build #{exception.transformation}. #{exception.message}"
  end

  def tty_log_completion
    status = @job_logger.success ? 'Success' : 'Failed'
    output = "\nCompleted job "
    output += "'#{@job.name}'".bold if @job.name
    output += " in #{ChronicDuration.output(@job_logger.duration)}" if @job_logger.duration
    output += "\n  Status:\t".light_black + status
    output += "\n  Completed:\t".light_black + "#{@job_logger.job_log.num_records_processed}"
    output += "\n  Latest:\t".light_black + "#{@job_logger.job_log.highest_timestamp.iso8601}" if @job_logger.job_log.highest_timestamp
    output
  end
end
