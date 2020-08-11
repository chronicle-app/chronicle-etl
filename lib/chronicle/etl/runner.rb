class Chronicle::Etl::Runner
  BUILTIN = {
    extractor: ['stdin', 'json', 'csv', 'file'],
    transformer: ['null'],
    loader: ['stdout', 'csv', 'table']
  }.freeze

  def initialize(options)
    @options = options

    instantiate_etl_classes
  end

  def run!
    progress_bar = Chronicle::Etl::Utils::ProgressBar.new(title: "Running job", total: @extractor.results_count)
    count = 0

    @loader.start

    @extractor.extract do |result|
      @loader.first_load(result) if count == 0

      transformed_data = @transformer.transform(result)
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

  def load_etl_class(phase, name)
    if BUILTIN[phase].include? name
      klass_name = "Chronicle::Etl::#{phase.to_s.capitalize}s::#{name.capitalize}#{phase.to_s.capitalize}"
    else
      # TODO: come up with syntax for specifying a particular extractor in a provider library
      # provider, extractor = name.split(":")
      provider = name
      begin
        require "chronicle/#{provider}"
      rescue LoadError => e
        warn("Error loading #{phase} '#{provider}'")
        warn("  Perhaps you haven't installed it yet: `$ gem install chronicle-#{provider}`")
        exit(false)
      end
      klass_name = "Chronicle::#{name.capitalize}::ChronicleTransformer"
    end
    Object.const_get(klass_name)
  end
end
