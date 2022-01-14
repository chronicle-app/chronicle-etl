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
    @progress_bar.log(tty_log_job_start)

    extractor.extract do | extraction |
      unless extraction.is_a?(Chronicle::ETL::Extraction)
        raise Chronicle::ETL::RunnerTypeError, "Extracted should be a Chronicle::ETL::Extraction"
      end

      transformer = @job.instantiate_transformer(extraction)
      record = transformer.transform

      unless record.is_a?(Chronicle::ETL::Models::Base)
        raise Chronicle::ETL::RunnerTypeError, "Transformed data should be a type of Chronicle::ETL::Models"
      end

      @job_logger.log_transformation(transformer)
      loader.load(record)
      @progress_bar.increment
      @progress_bar.log(tty_log_transformation(transformer)) if @job.log_each_transformation?
    end

    @progress_bar.log("")
    @progress_bar.finish
    loader.finish
    @job_logger.finish
    @job_logger.save
    @progress_bar.log("")

    tty_log_completion.split("\n").each do |line|
      @progress_bar.log(line)
    end
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

  def tty_log_completion
    output = "Completed job "
    output += "'#{@job.name}'".bold if @job.name
    output += " in #{ChronicDuration.output(@job_logger.duration)}"
    output += "\n  Status:\t".light_black + "Success"
    output += "\n  Completed:\t".light_black + "#{@job_logger.job_log.num_records_processed}"
    output += "\n  Latest:\t".light_black + "#{@job_logger.job_log.highest_timestamp.iso8601}" if @job_logger.job_log.highest_timestamp
    output
  end
end
