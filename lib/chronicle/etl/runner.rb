class Chronicle::Etl::Runner
  def initialize(options)
    @options = options

    instantiate_etl_classes
  end

  def run!
    progress_bar = Chronicle::Etl::Utils::ProgressBarWrapper.new(@extractor.results_count)
    @loader.start

    @extractor.extract do |result, i|
      @loader.first_load(result) if i == 0

      transformed_data = @transformer.transform(result)
      @loader.load(transformed_data)

      progress_bar.increment
    end

    progress_bar.finish
    @loader.finish
  end

  private

  def instantiate_etl_classes
    @extractor = get_etl_class(:extractor, @options[:extractor][:name]).new(@options[:extractor][:options])
    @transformer = get_etl_class(:transformer, @options[:transformer][:name]).new(@options[:transformer][:options])
    @loader = get_etl_class(:loader, @options[:loader][:name]).new(@options[:loader][:options])
  end

  def get_etl_class(phase, name)
    klass_name = "Chronicle::Etl::#{phase.to_s.capitalize}s::#{name.capitalize}"
    Object.const_get(klass_name)
  end
end
