require "ostruct"

module Chronicle
  module ETL
    module Configurable

      # An individual setting for this Configurable 
      Setting = Struct.new(:default, :required, :type) do
      end

      # Collection of user-supplied options for this Configurable
      class Config < OpenStruct
        def compacted_h
          to_h.compact
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
        klass.prepend(Initializer)
      end

      module Initializer
        def initialize *args
          @config = initialize_default_config
          super
        end
      end

      module InstanceMethods
        attr_reader :config

        def apply_options(options)
          options = options.transform_keys!(&:to_sym)
          options.each do |name, value|
            raise Chronicle::ETL::ConfigurationError.new "Unrecognized setting: #{name}" unless self.class.has_setting?(name)
            
            # TODO: 
            @config[name] = value
          end
          validate_options
          options
        end

        private

        def initialize_default_config
          self.class.config_with_defaults
        end

        def validate_options
          missing = (self.class.all_required_settings.keys - @config.compacted_h.keys)
          if missing.count > 0
            raise Chronicle::ETL::ConfigurationError.new "Missing options: #{missing}"
          end
        end

        # Was originally in Extractor
        # Saving for use in type coercion system
        # def sanitize_options
        #   @config.since = Time.parse(@config.since) if @config.since && @config.since.is_a?(String)
        #   @config.until = Time.parse(@config.until) if @config.until && @config.until.is_a?(String)
        # end
      end

      module ClassMethods
        def setting(name, default: nil, required: false, type: :string)
          s = Setting.new(default, required, type)
          settings[name] = s
        end

        def all_settings
          if self.superclass == Object
            settings
          else 
            self.superclass.all_settings.merge(settings)
          end
        end

        def all_required_settings
          all_settings.select{ |name, setting| setting.required } || {}
        end

        def settings
          @settings ||= {}
        end

        def has_setting? name
          all_settings.keys.include? name
        end

        def config_with_defaults
          s = all_settings.transform_values do |setting|
            setting.default
          end
          Config.new(s)
        end
      end
    end
  end
end
