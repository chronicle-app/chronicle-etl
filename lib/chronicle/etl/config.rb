require 'runcom'

module Chronicle
  module ETL
    # Utility methods to read, write, and access config files
    module Config
      # Loads a yml config file
      def self.load(path)
        config = Runcom::Config.new(path)
        # FIXME: hack to deeply symbolize keys
        JSON.parse(config.to_h.to_json, symbolize_names: true)
      end

      # Writes a hash as a yml config file
      def self.write(path, data)
        config = Runcom::Config.new(path)
        filename = config.all[0].to_s + '.yml'
        File.open(filename, 'w') do |f|
          f << data.to_yaml
        end
      end

      # Returns all jobs available in ~/.config/chronicle/etl/jobs/*.yml
      def self.jobs
        job_directory = Runcom::Config.new('chronicle/etl/jobs').current
        Dir.glob(File.join(job_directory, "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end
    end
  end
end
