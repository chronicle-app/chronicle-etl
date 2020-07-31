require 'thor'
require 'chronicle/etl'

module Chronicle
  module Etl
    class CLI < Thor
      default_task :job

      desc 'job', 'Runs an ETL job'
      method_option :extractor, aliases: '-e', desc: 'Extractor class (available: stdin, csv, file)', default: 'stdin', banner: 'extractor-name'
      method_option :'extractor-opts', desc: 'Extractor options', type: :hash, default: {}
      method_option :transformer, aliases: '-t', desc: 'Transformer class (available: null)', default: 'null', banner: 'transformer-name'
      method_option :'transformer-opts', desc: 'Transformer options', type: :hash, default: {}
      method_option :loader, aliases: '-l', desc: 'Loader class (available: stdout, csv, table)', default: 'stdout', banner: 'loader-name'
      method_option :'loader-opts', desc: 'Loader options', type: :hash, default: {}
      method_option :job, aliases: '-j', desc: 'Job configuration file'
      def job
        runner_options = {
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

        runner = Runner.new(runner_options)
        runner.run!
      end
    end
  end
end
