require 'pp'
module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL jobs
      class Jobs < SubcommandBase
        default_task "start"
        namespace :jobs

        class_option :extractor, aliases: '-e', desc: "Extractor class. Default: stdin", banner: 'extractor-name'
        class_option :'extractor-opts', desc: 'Extractor options', type: :hash, default: {}
        class_option :transformer, aliases: '-t', desc: 'Transformer class. Default: null', banner: 'transformer-name'
        class_option :'transformer-opts', desc: 'Transformer options', type: :hash, default: {}
        class_option :loader, aliases: '-l', desc: 'Loader class. Default: stdout', banner: 'loader-name'
        class_option :'loader-opts', desc: 'Loader options', type: :hash, default: {}
        class_option :name, aliases: '-j', desc: 'Job configuration name'

        map run: :start  # Thor doesn't like `run` as a command name
        desc "run", "Start a job"
        option :log_level, desc: 'Log level (debug, info, warn, error, fatal)', default: 'info'
        option :verbose, aliases: '-v', desc: 'Set log level to verbose', type: :boolean
        option :dry_run, desc: 'Only run the extraction and transform steps, not the loading', type: :boolean
        long_desc <<-LONG_DESC
          This will run an ETL job. Each job needs three parts:

            1. #{'Extractor'.underline}: pulls data from an external source. By default, this is stdout. Other common options including pulling data from an API or reading JSON from a file.

            2. #{'Transformer'.underline}: transforms data into a new format. If none is specified, we use the `null` transformer which does nothing to the data.

            3. #{'Loader'.underline}: takes that transformed data and loads it externally. This can be an API, flat files, (or by default), stdout. With the --dry-run option, this step won't be run.

            If you do not want to use the command line flags, you can also configure a job with a .yml config file. You can either specify the path to this file or use the filename and place the file in ~/.config/chronicle/etl/jobs/NAME.yml and call it with `--job NAME`
LONG_DESC
        # Run an ETL job
        def start
          setup_log_level
          job_definition = build_job_definition(options)
          job = Chronicle::ETL::Job.new(job_definition)
          runner = Chronicle::ETL::Runner.new(job)
          runner.run!
        end

        desc "create", "Create a job"
        # Create an ETL job
        def create
          job_definition = build_job_definition(options)
          path = File.join('chronicle', 'etl', 'jobs', options[:name])
          Chronicle::ETL::Config.write(path, job_definition.definition)
        end

        desc "show", "Show details about a job"
        # Show an ETL job
        def show
          puts Chronicle::ETL::Job.new(build_job_definition(options))
        end

        desc "list", "List all available jobs"
        # List available ETL jobs
        def list
          jobs = Chronicle::ETL::Config.available_jobs

          job_details = jobs.map do |job|
            r = Chronicle::ETL::Config.load("chronicle/etl/jobs/#{job}.yml")

            extractor = r[:extractor][:name] if r[:extractor]
            transformer = r[:transformer][:name] if r[:transformer]
            loader = r[:loader][:name] if r[:loader]

            [job, extractor, transformer, loader]
          end

          headers = ['name', 'extractor', 'transformer', 'loader'].map{|h| h.upcase.bold }

          table = TTY::Table.new(headers, job_details)
          puts table.render(indent: 0, padding: [0, 2])
        end

        private

        def setup_log_level
          if options[:verbose]
            Chronicle::ETL::Logger.log_level = Chronicle::ETL::Logger::DEBUG
          elsif options[:log_level]
            level = Chronicle::ETL::Logger.const_get(options[:log_level].upcase)
            Chronicle::ETL::Logger.log_level = level 
          end
        end

        # Create job definition by reading config file and then overwriting with flag options
        def build_job_definition(options)
          definition = Chronicle::ETL::JobDefinition.new
          definition.add_config(load_job_config(options[:name]))
          definition.add_config(process_flag_options(options))
          definition
        end

        def load_job_config name
          Chronicle::ETL::Config.load_job_from_config(name)
        end

        # Takes flag options and turns them into a runner config
        def process_flag_options options
          {
            dry_run: options[:dry_run],
            extractor: {
              name: options[:extractor],
              options: options[:'extractor-opts']
            }.compact,
            transformer: {
              name: options[:transformer],
              options: options[:'transformer-opts']
            }.compact,
            loader: {
              name: options[:loader],
              options: options[:'loader-opts']
            }.compact
          }
        end
      end
    end
  end
end
