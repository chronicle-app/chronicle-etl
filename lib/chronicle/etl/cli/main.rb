require 'colorize'

module Chronicle
  module ETL
    module CLI
      # Main entrypoint for CLI app
      class Main < Chronicle::ETL::CLI::CLIBase
        class_before :set_log_level
        class_before :set_color_output

        class_option :log_level, desc: 'Log level (debug, info, warn, error, fatal, silent)', default: 'info'
        class_option :verbose, aliases: '-v', desc: 'Set log level to verbose', type: :boolean
        class_option :silent, desc: 'Silence all output', type: :boolean
        class_option :'no-color', desc: 'Disable colour output', type: :boolean

        default_task "jobs"

        desc 'connectors:COMMAND', 'Connectors available for ETL jobs', hide: true
        subcommand 'connectors', Connectors

        desc 'jobs:COMMAND', 'Configure and run jobs', hide: true
        subcommand 'jobs', Jobs

        desc 'plugins:COMMAND', 'Configure plugins', hide: true
        subcommand 'plugins', Plugins

        desc 'secrets:COMMAND', 'Manage secrets', hide: true
        subcommand 'secrets', Secrets

        # Entrypoint for the CLI
        def self.start(given_args = ARGV, config = {})
          # take a subcommand:command and splits them so Thor knows how to hand off to the subcommand class
          if given_args.any? && given_args[0].include?(':')
            commands = given_args.shift.split(':')
            given_args = given_args.unshift(commands).flatten
          end

          super(given_args, config)
        end

        def self.exit_on_failure?
          true
        end

        desc "version", "Show version"
        map %w(--version -v) => :version
        def version
          shell.say "chronicle-etl #{Chronicle::ETL::VERSION}"
        end

        # Displays help options for chronicle-etl
        def help(meth = nil, subcommand = false)
          if meth && !respond_to?(meth)
            klass, task = ::Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
            klass.start(['-h', task].compact, shell: shell)
          else
            shell.say "ABOUT".bold
            shell.say "  #{'chronicle-etl'.italic} is a utility tool for #{'extracting'.underline}, #{'transforming'.underline}, and #{'loading'.underline} personal data."
            shell.say
            shell.say "USAGE".bold
            shell.say "  $ chronicle-etl COMMAND"
            shell.say
            shell.say "EXAMPLES".bold
            shell.say "  Show available connectors:".italic.light_black
            shell.say "  $ chronicle-etl connectors:list"
            shell.say
            shell.say "  Run a simple job:".italic.light_black
            shell.say "  $ chronicle-etl jobs:run --extractor stdin --transformer null --loader stdout"
            shell.say
            shell.say "  Show full job options:".italic.light_black
            shell.say "  $ chronicle-etl jobs help run"

            list = []

            ::Thor::Util.thor_classes_in(Chronicle::ETL::CLI).each do |thor_class|
              list += thor_class.printable_tasks(false)
            end
            list.sort! { |a, b| a[0] <=> b[0] }
            list.unshift ["help", "# This help menu"]

            shell.say
            shell.say 'ALL COMMANDS'.bold
            shell.print_table(list, indent: 2, truncate: true)
            shell.say
            shell.say "VERSION".bold
            shell.say "  #{Chronicle::ETL::VERSION}"
            shell.say
            shell.say "  Display current version:".italic.light_black
            shell.say "  $ chronicle-etl --version"
            shell.say
            shell.say "FULL DOCUMENTATION".bold
            shell.say "  https://github.com/chronicle-app/chronicle-etl".blue
            shell.say
          end
        end

        no_commands do
          def testb
            puts "hi"
          end
          def set_color_output
            String.disable_colorization true if options[:'no-color'] || ENV['NO_COLOR']
          end

          def set_log_level
            if options[:silent]
              Chronicle::ETL::Logger.log_level = Chronicle::ETL::Logger::SILENT
            elsif options[:verbose]
              Chronicle::ETL::Logger.log_level = Chronicle::ETL::Logger::DEBUG
            elsif options[:log_level]
              level = Chronicle::ETL::Logger.const_get(options[:log_level].upcase)
              Chronicle::ETL::Logger.log_level = level
            end
          end
        end
      end
    end
  end
end
