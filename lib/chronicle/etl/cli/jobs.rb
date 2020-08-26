module Chronicle
  module Etl
    module CLI
      # CLI commands for working with ETL jobs
      class Jobs < SubcommandBase
        default_task "start"
        map run: :start
        namespace :jobs

        method_option :extractor, aliases: '-e', desc: 'Extractor class (available: stdin, csv, file)', default: 'stdin', banner: 'extractor-name'
        method_option :'extractor-opts', desc: 'Extractor options', type: :hash, default: {}
        method_option :transformer, aliases: '-t', desc: 'Transformer class (available: null)', default: 'null', banner: 'transformer-name'
        method_option :'transformer-opts', desc: 'Transformer options', type: :hash, default: {}
        method_option :loader, aliases: '-l', desc: 'Loader class (available: stdout, csv, table)', default: 'stdout', banner: 'loader-name'
        method_option :'loader-opts', desc: 'Loader options', type: :hash, default: {}
        method_option :job, aliases: '-j', desc: 'Job configuration name (or filename)'
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
          runner_options = build_job_config(options)
          runner = Runner.new(runner_options)
          runner.run!
        end

        desc "create", "Create a job"
        # Create an ETL job
        def create
          abort "Not implemented yet".red
        end

        desc "show", "Show a job"
        # Show an ETL job
        def show
          abort "Not implemented yet".red
        end

        desc "list", "List all available jobs"
        # List available ETL jobs
        def list
          abort "Not implemented yet".red
        end

        private

        def build_job_config options
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
