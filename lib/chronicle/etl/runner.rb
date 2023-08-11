require 'colorize'
require 'chronic_duration'
require "tty-spinner"

class Chronicle::ETL::Runner
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
    raise(Chronicle::ETL::RunInterruptedError, "Job interrupted.")
  rescue StandardError => e
    # Just throwing this in here until we have better exception handling in
    # loaders, etc
    @job_logger&.error
    raise(Chronicle::ETL::RunnerError, "Error running job. #{e.message}")
  ensure
    finish_job
  end

  private

  def begin_job
    Chronicle::ETL::Logger.info(tty_log_job_initialize)
    @initialization_spinner = TTY::Spinner.new(":spinner :title", format: :dots_2)
  end

  def validate_job
    @initialization_spinner.update(title: "Validating job")
    @job.job_definition.validate!
  end

  def instantiate_connectors
    @initialization_spinner.update(title: "Initializing connectors")
    @extractor = @job.instantiate_extractor
    @loader = @job.instantiate_loader
  end

  def prepare_job
    @initialization_spinner.update(title: "Preparing job")
    @job_logger.start
    @loader.start

    @initialization_spinner.update(title: "Preparing extraction")
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
    @extractor.extract do |extraction|
      process_extraction(extraction)
      @progress_bar.increment
    end

    @progress_bar.finish

    # This is typically a slow method (writing to stdout, writing a big file, etc)
    # TODO: consider adding a spinner?
    @loader.finish
    @job_logger.finish
  end

  def process_extraction(extraction)
    # For each extraction from our extractor, we create a new transformer
    transformer = @job.instantiate_transformer(extraction)

    # And then transform the record, capturing the new object(s)
    new_objects = [transformer.transform].flatten

    # raise an error unless all new_objects are a Base
    unless new_objects.all? { |r| r.is_a?(Chronicle::Schema::Base) }
      raise(Chronicle::ETL::RunnerError, "Expected transformer to output a Chronicle Schema model")
    end

    Chronicle::ETL::Logger.debug(tty_log_transformation(transformer))
    @job_logger.log_transformation(transformer)

    # Then send the results to the loader
    new_objects.each do |object|
      @loader.load(object) unless @job.dry_run?
    end
  rescue Chronicle::ETL::TransformationError => e
    # TODO: have an option to cancel job if we encounter an error
    Chronicle::ETL::Logger.error(tty_log_transformation_failure(e, transformer))
  end

  def finish_job
    @job_logger.save
    @progress_bar&.finish
    Chronicle::ETL::Logger.detach_from_ui
    Chronicle::ETL::Logger.info(tty_log_completion)
  end

  def tty_log_job_initialize
    output = "Beginning job "
    output += "'#{@job.name}'".bold if @job.name
    output
  end

  def tty_log_transformation(transformer)
    output = "  ✓".green
    output += " #{transformer}"
  end

  def tty_log_transformation_failure(exception, transformer)
    output = "  ✖".red
    output += " Failed to transform #{transformer}. #{exception.message}"
  end

  def tty_log_completion
    status = @job_logger.success ? 'Success' : 'Failed'
    job_completion = @job_logger.success ? 'Completed' : 'Partially completed'
    output = "\n#{job_completion} job"
    output += " '#{@job.name}'".bold if @job.name
    output += " in #{ChronicDuration.output(@job_logger.duration)}" if @job_logger.duration
    output += "\n  Status:\t".light_black + status
    output += "\n  Completed:\t".light_black + "#{@job_logger.job_log.num_records_processed}"
    output += "\n  Latest:\t".light_black + "#{@job_logger.job_log.highest_timestamp.iso8601}" if @job_logger.job_log.highest_timestamp
    output
  end
end
