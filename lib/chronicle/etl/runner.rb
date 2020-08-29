require 'colorize'

class Chronicle::ETL::Runner
  def initialize(options = {})
    @options = options
  end

  def run!
    extractor = instantiate_klass(:extractor)
    loader = instantiate_klass(:loader)

    total = extractor.results_count
    progress_bar = Chronicle::ETL::Utils::ProgressBar.new(title: 'Running job', total: total)

    loader.start

    extractor.extract do |data, metadata|
      transformer = instantiate_klass(:transformer, data)
      transformed_data = transformer.transform

      loader.load(transformed_data)
      progress_bar.increment
    end

    progress_bar.finish
    loader.finish
  end

  private

  def instantiate_klass(phase, *args)
    klass = load_etl_class(phase, @options[phase][:name])
    klass.new(@options[phase][:options], *args)
  end

  def load_etl_class(phase, identifier)
    Chronicle::ETL::Catalog.identifier_to_klass(phase: phase, identifier: identifier)
  rescue Chronicle::ETL::ProviderNotAvailableError => e
    warn(e.message.red)
    warn("  Perhaps you haven't installed it yet: `$ gem install chronicle-#{e.provider}`")
    exit(false)
  rescue Chronicle::ETL::ConnectorNotAvailableError => e
    warn(e.message.red)
    exit(false)
  end
end
