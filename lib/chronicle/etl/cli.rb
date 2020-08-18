require 'thor'
require 'chronicle/etl'
require 'colorize'

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

      # FIXME: namespace this differently
      desc 'list', 'List all ETL classes'
      def list
        klasses = Chronicle::Etl::Catalog.available_classes
        klasses = klasses.sort_by do |a|
          [a[:built_in].to_s, a[:provider], a[:phase]]
        end

        headers = klasses.first.keys.map do |key|
          key.to_s.capitalize.light_white
        end

        table = TTY::Table.new(headers, klasses.map(&:values))
        puts table.render(padding: [0, 2])
      end
    end
  end
end
