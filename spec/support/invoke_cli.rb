module Chronicle
  module ETL
    module SpecHelpers
      def invoke_cli args=[]
        capture(:stdout) do
          Chronicle::ETL::CLI::Main.start(args)
        end
      end
    end
  end
end
