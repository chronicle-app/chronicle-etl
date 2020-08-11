require 'csv'
class Chronicle::Etl::Extractors::CsvExtractor < Chronicle::Etl::Extractors::Extractor
  DEFAULT_OPTIONS = {
    headers: true,
    filename: $stdin
  }.freeze

  def initialize(options = {})
    super(DEFAULT_OPTIONS.merge(options))
  end

  def extract
    csv = initialize_csv
    csv.each do |row|
      result = row.to_h
      yield result
    end
  end

  def results_count
    CSV.read(@options[:filename], headers: @options[:headers]).count if read_from_file?
  end

  private

  def initialize_csv
    headers = @options[:headers].is_a?(String) ? @options[:headers].split(',') : @options[:headers]

    csv_options = {
      headers: headers,
      header_converters: :symbol,
      converters: [:all]
    }

    stream = read_from_file? ? File.open(@options[:filename]) : @options[:filename]
    CSV.new(stream, **csv_options)
  end

  def read_from_file?
    @options[:filename] != $stdin
  end
end
