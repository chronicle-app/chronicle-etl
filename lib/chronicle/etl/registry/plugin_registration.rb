module Chronicle
  module ETL
    module Registry
      class PluginRegistration
        attr_accessor :name, :description, :gem, :version, :installed, :gemspec

        def initialize(name=nil)
          @installed = false
          @name = name
          yield self if block_given?
        end

        def installed?
          @installed || false
        end
      end
    end
  end
end
