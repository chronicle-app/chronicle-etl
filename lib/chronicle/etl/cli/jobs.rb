require 'pp'
module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL jobs
      class Jobs < SubcommandBase
        default_task "start"
        namespace :jobs

        class_option :extractor, aliases: '-e', desc: 'Extractor class (available: stdin, csv, file)', default: 'stdin', banner: 'extractor-name'
        class_option :'extractor-opts', desc: 'Extractor options', type: :hash, default: {}
        class_option :transformer, aliases: '-t', desc: 'Transformer class (available: null)', default: 'null', banner: 'transformer-name'
        class_option :'transformer-opts', desc: 'Transformer options', type: :hash, default: {}
        class_option :loader, aliases: '-l', desc: 'Loader class (available: stdout, csv, table)', default: 'stdout', banner: 'loader-name'
        class_option :'loader-opts', desc: 'Loader options', type: :hash, default: {}
        class_option :name, aliases: '-j', desc: 'Job configuration name'

        map run: :start  # Thor doesn't like `run` as a command name
        desc "run", "Start a job"
        long_desc <<-LONG_DESC
          This will run an ETL job. Each job needs three parts:

            1. #{'Extractor'.underline}: pulls data from an external source. By default, this is stdout. Other common options including pulling data from an API or reading JSON from a file.

            2. #{'Transformer'.underline}: transforms data into a new format. If none is specified, we use the `null` transformer which does nothing to the data.

            3. #{'Loader'.underline}: takes that transformed data and loads it externally. This can be an API, flat files, (or by default), stdout.

            If you do not want to use the command line flags, you can also configure a job with a .yml config file. You can either specify the path to this file or use the filename and place the file in ~/.config/chronicle/etl/jobs/NAME.yml and call it with `--job NAME`
LONG_DESC
        # Run an ETL job
        def start
          job_definition = build_job_definition(options)
          job = Chronicle::ETL::Job.new(job_definition)
          runner = Chronicle::ETL::Runner.new(job)
          runner.run!
        rescue Chronicle::ETL::ProviderNotAvailableError => e
          warn(e.message.red)
          warn("  Perhaps you haven't installed it yet: `$ gem install chronicle-#{e.provider}`")
          exit(false)
        rescue Chronicle::ETL::ConnectorNotAvailableError => e
          warn(e.message.red)
          exit(false)
        end

        desc "create", "Create a job"
        # Create an ETL job
        def create
          job_definition = build_job_definition(options)
          path = File.join('chronicle', 'etl', 'jobs', options[:name])
          Chronicle::ETL::Config.write(path, job_definition)
        end

        desc "show", "Show details about a job"
        # Show an ETL job
        def show
          job_config = build_job_definition(options)
          pp job_config
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

        # Create job definition by reading config file and then overwriting with flag options
        def build_job_definition(options)
          definition = Chronicle::ETL::JobDefinition.new
          definition.add_config(process_flag_options(options))
          definition.add_config(load_job_config(options[:name]))
          definition
        end

        def load_job_config name
          Chronicle::ETL::Config.load_job_from_config(name)
        end

        # Takes flag options and turns them into a runner config
        def process_flag_options options
          {
            extractor: {
              name: options[:extractor],
              options: options[:'extractor-opts']
            },
            transformer: {
              name: options[:transformer],
              options: options[:'transformer-opts']
            },
            loader: {
              name: options[:loader],
              options: options[:'loader-opts']
            }
          }
        end
      end
    end
  end
end
