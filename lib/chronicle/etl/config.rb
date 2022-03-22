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

      # Returns all available secrets available in ~/.config/chronicle/etl/secrets/*.yml
      def available_secret_namespaces
        Dir.glob(File.join(config_directory("secrets"), "*.yml")).map do |filename|
          File.basename(filename, ".*")
        end
      end

      def write_secrets(namespace, secrets)
        data = {
          provider: namespace,
          secrets: (secrets || {}).transform_keys(&:to_s),
          chronicle_etl_version: Chronicle::ETL::VERSION
        }.transform_keys(&:to_s) # Should I implement deeply_transform_keys ?
        self.write("chronicle/etl/secrets/#{namespace}.yml", data)
      end

      def load_secrets_from_config(namespace)
        definition = self.load("chronicle/etl/secrets/#{namespace}.yml")
        definition[:secrets] || {}
      end

      # Load a job definition from job config directory
      def load_job_from_config(job_name)
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
