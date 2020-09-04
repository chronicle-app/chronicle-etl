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

    extractor.extract do |data, metadata|
      transformer = @job.instantiate_transformer(data)
      transformed_data = transformer.transform
      @job_logger.log_transformation(transformer)
      loader.load(transformed_data)
      progress_bar.increment
    end

    progress_bar.finish
    loader.finish
    @job_logger.finish
    @job_logger.save
  end
end
