module Chronicle
  module ETL
    module SpecHelpers
      # Run the main CLI app with given args
      #
      # @param [Array] the command line arguments to pass to the CLI
      # @param [Boolean] rescue_from_exit whether to rescue when CLI explictly
      #   exits. If set to false, example must include
      #   `.to raise_error(SystemExit)`, otherwise tests will prematurely end
      def invoke_cli(args = [], rescue_from_exit = true)
        capture do
          Chronicle::ETL::CLI::Main.start(args)
        rescue SystemExit
          raise unless rescue_from_exit
        end
      end
    end
  end
end
