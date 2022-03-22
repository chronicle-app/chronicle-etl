# frozen_string_literal: true

require "tty-prompt"

module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL plugins
      class Secrets < SubcommandBase
        default_task 'list'
        namespace :secrets

        desc "set NAMESPACE KEY [VALUE]", "Add a secret. VALUE can be set as argument or from stdin"
        def set(namespace, key, value=nil)
          validate_namespace(namespace)

          if value
            # came as argument
          elsif $stdin.stat.pipe?
            value = $stdin.read
          else
            prompt = TTY::Prompt.new
            value = prompt.mask("Please enter #{key} for #{namespace}:")
          end

          Chronicle::ETL::Secrets.set(namespace, key, value.strip)
          cli_exit(message: "Secret set")
        rescue TTY::Reader::InputInterrupt
          cli_fail(message: "\nSecret not set")
        end

        desc "unset NAMESPACE KEY", "Remove a secret"
        def unset(namespace, key)
          validate_namespace(namespace)

          Chronicle::ETL::Secrets.unset(namespace, key)
          cli_exit(message: "Secret unset")
        end

        desc "list", "List available secrets"
        def list(namespace=nil)
          all_secrets = Chronicle::ETL::Secrets.all(namespace)
          cli_exit(message: "No secrets saved") unless all_secrets.any?

          rows = []
          all_secrets.each do |namespace, secrets|
            rows += secrets.map do |key, value|
              # hidden_value = (value[0..5] + ("*" * [0, [value.length - 5, 30].min].max)).truncate(30)
              truncated_value = value.truncate(30)
              [namespace, key, truncated_value]
            end
          end

          headers = ['namespace', 'key', 'value'].map { |h| h.upcase.bold }

          puts "Available secrets:"
          table = TTY::Table.new(headers, rows)
          puts table.render(indent: 0, padding: [0, 2])
        end

        private

        def validate_namespace(namespace)
          cli_fail(message: "'#{namespace}' is not a valid namespace") unless Chronicle::ETL::Secrets.valid_namespace_name?(namespace)
        end
      end
    end
  end
end
