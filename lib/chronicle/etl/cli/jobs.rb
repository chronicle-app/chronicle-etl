require 'pp'
require 'pry'

module Chronicle
  module Etl
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
        class_option :job, aliases: '-j', desc: 'Job configuration name (or filename)'

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
          runner_options = build_runner_options(options)
          runner = Chronicle::Etl::Runner.new(runner_options)
          runner.run!
        end

        desc "create", "Create a job"
        # Create an ETL job
        def create
          runner_options = build_runner_options(options)
          path = File.join('chronicle', 'etl', 'jobs', options[:job])
          Chronicle::Etl::Config.write(path, runner_options)
        end

        desc "show", "Show details about a job"
        # Show an ETL job
        def show
          runner_options = build_runner_options(options)
          pp runner_options
        end

        desc "list", "List all available jobs"
        # List available ETL jobs
        def list
          jobs = Chronicle::Etl::Config.jobs

          job_details = jobs.map do |job|
            r = Chronicle::Etl::Config.load("chronicle/etl/jobs/#{job}.yml")

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

        # Create runner options by reading config file and then overwriting with flag options
        def build_runner_options options
          flag_options = process_flag_options(options)
          job_options = load_job(options[:job])
          flag_options.merge(job_options)
        end

        def load_job job
          yml_config = Chronicle::Etl::Config.load("chronicle/etl/jobs/#{job}.yml")
          # FIXME: use better trick to depely symbolize keys
          JSON.parse(yml_config.to_json, symbolize_names: true)
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
