require 'runcom'

module Chronicle
  module ETL
    # Utility methods to read, write, and access config files
    module Config
      module_function

      # Loads a yml config file
      def load(path)
        config = Runcom::Config.new(path)
        # FIXME: hack to deeply symbolize keys
        JSON.parse(config.to_h.to_json, symbolize_names: true)
      end

      # Writes a hash as a yml config file
      def write(path, data)
        config = Runcom::Config.new(path)
        filename = config.all[0].to_s + '.yml'
        File.open(filename, 'w') do |f|
          f << data.to_yaml
        end
      end

      # Returns all jobs available in ~/.config/chronicle/etl/jobs/*.yml
      def jobs
        job_directory = Runcom::Config.new('chronicle/etl/jobs').current
        Dir.glob(File.join(job_directory, "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      # Load a job definition from job config directory
      def load_job_from_config(job_name)
        definition = self.load("chronicle/etl/jobs/#{job_name}.yml")
        # FIXME: use better trick to depely symbolize keys
        JSON.parse(definition.to_json, symbolize_names: true)
        definition[:name] = job_name
        definition
      end
    end
  end
end
