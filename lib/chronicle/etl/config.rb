require 'runcom'
require 'fileutils'

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
        filename = config.all[1].to_s
        FileUtils.mkdir_p(File.dirname(filename))
        File.open(filename, 'w') do |f|
          # Ruby likes to add --- separators when writing yaml files
          f << data.to_yaml.gsub(/^-+\n/, '')
        end
      end

      # Returns all jobs available in ~/.config/chronicle/etl/jobs/*.yml
      def available_jobs
        Dir.glob(File.join(config_directory("jobs"), "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      def available_configs(type)
        Dir.glob(File.join(config_directory(type), "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      # Load a job definition from job config directory
      def read_job(job_name)
        definition = self.load("chronicle/etl/jobs/#{job_name}.yml")
        definition[:name] = job_name
        definition
      end

      def config_directory(type)
        path = "chronicle/etl/#{type}"
        Runcom::Config.new(path).all[1] || raise(Chronicle::ETL::ConfigError, "Could not access config directory (#{path})")
      end
    end
  end
end
