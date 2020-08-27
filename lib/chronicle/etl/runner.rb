class Chronicle::ETL::Runner
  BUILTIN = {
    extractor: ['stdin', 'json', 'csv', 'file'],
    transformer: ['null'],
    loader: ['stdout', 'csv', 'table', 'rest']
  }.freeze

  def initialize(options)
    @options = options

    instantiate_etl_classes
  end

  def run!
    total = @extractor.results_count
    progress_bar = Chronicle::ETL::Utils::ProgressBar.new(title: 'Running job', total: total)
    count = 0

    @loader.start

    @extractor.extract do |data, metadata|
      transformed_data = @transformer.transform(data)
      @loader.load(transformed_data)

      progress_bar.increment
      count += 1
    end

    progress_bar.finish
    @loader.finish
  end

  private

  def instantiate_etl_classes
    @extractor = load_etl_class(:extractor, @options[:extractor][:name]).new(@options[:extractor][:options])
    @transformer = load_etl_class(:transformer, @options[:transformer][:name]).new(@options[:transformer][:options])
    @loader = load_etl_class(:loader, @options[:loader][:name]).new(@options[:loader][:options])
  end

  def load_etl_class(phase, x)
    if BUILTIN[phase].include? x
      klass_name = "Chronicle::ETL::#{x.capitalize}#{phase.to_s.capitalize}"
    else
      # TODO: come up with syntax for specifying a particular extractor in a provider library
      provider, name = x.split(":")
      provider = x unless provider
      begin
        require "chronicle/#{provider}"
      rescue LoadError => e
        warn("Error loading #{phase} '#{provider}'".red)
        warn("  Perhaps you haven't installed it yet: `$ gem install chronicle-#{provider}`")
        exit(false)
      end
      klass_name = "Chronicle::#{provider.capitalize}::#{name&.capitalize}#{phase.capitalize}"
    end
    Object.const_get(klass_name)
  end
end
