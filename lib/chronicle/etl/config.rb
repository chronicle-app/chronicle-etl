require 'fileutils'
require 'yaml'

module Chronicle
  module ETL
    # Utility methods to read, write, and access config files
    module Config
      module_function

      def load(type, identifier)
        base = config_pathname_for_type(type)
        path = base.join("#{identifier}.yml")
        return {} unless path.exist?

        YAML.safe_load(File.read(path), symbolize_names: true, permitted_classes: [Symbol, Date, Time])
      end

      # Writes a hash as a yml config file
      def write(type, identifier, data)
        base = config_pathname_for_type(type)
        path = base.join("#{identifier}.yml")
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w', 0o600) do |f|
          # Ruby likes to add --- separators when writing yaml files
          f << data.to_yaml.gsub(/^-+\n/, '')
        end
      end

      # Returns all jobs available in ~/.config/chronicle/etl/jobs/*.yml
      def available_jobs
        Dir.glob(File.join(config_pathname_for_type("jobs"), "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      def available_configs(type)
        Dir.glob(File.join(config_pathname_for_type(type), "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      # Load a job definition from job config directory
      def read_job(job_name)
        load('jobs', job_name)
      end

      def config_pathname
        base = Pathname.new(XDG::Config.new.home)
        base.join('chronicle', 'etl')
      end

      def config_pathname_for_type(type)
        config_pathname.join(type)
      end
    end
  end
end
