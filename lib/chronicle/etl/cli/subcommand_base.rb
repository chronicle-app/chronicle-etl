module Chronicle
  module Etl
    module CLI
      # Base class for CLI subcommands. Overrides Thor methods so we can use command:subcommand syntax
      class SubcommandBase < Thor
        # Print usage instructions for a subcommand
        def self.help(shell, subcommand = false)
          list = printable_commands(true, subcommand)
          Thor::Util.thor_classes_in(self).each do |klass|
            list += klass.printable_commands(false)
          end
          list.sort! { |a, b| a[0] <=> b[0] }

          shell.say "COMMANDS".bold
          shell.print_table(list, indent: 2, truncate: true)
          shell.say
          class_options_help(shell)
        end

        # Show docs with command:subcommand pattern.
        # For `help` command, don't use colon
        def self.banner(command, namespace = nil, subcommand = false)
          if command.name == 'help'
            "#{subcommand_prefix} #{command.usage}"
          else
            "#{subcommand_prefix}:#{command.usage}"
          end
        end

        # Use subcommand classname to derive display name for subcommand
        def self.subcommand_prefix
          self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
        end
      end
    end
  end
end
