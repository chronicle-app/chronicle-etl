require 'colorize'

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
    progress_bar = Chronicle::ETL::Utils::ProgressBar.new(title: 'Running job', total: total)

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
      progress_bar.increment
    end

    progress_bar.finish
    loader.finish
    @job_logger.finish
    @job_logger.save
  end
end
