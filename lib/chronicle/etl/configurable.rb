# frozen_string_literal: true

require "ostruct"
require "chronic_duration"

module Chronicle
  module ETL
    # A mixin that gives a class
    # a {Chronicle::ETL::Configurable::ClassMethods#setting} macro to define
    # settings and their properties (require, type, etc)
    #
    # @example Basic usage
    #   class Test < Chronicle::ETL::Extractor
    #     include Chronicle::ETL::Configurable
    #     setting :when, type: :date, required: true
    #   end
    #
    #   t = Test.new(when: '2022-02-24')
    #   t.config.when
    module Configurable
      # An individual setting for this Configurable
      Setting = Struct.new(:default, :required, :type, :description)
      private_constant :Setting

      # Collection of user-supplied options for this Configurable
      class Config < OpenStruct
        # Config values that aren't nil, as a hash
        def compacted_h
          to_h.compact
        end
      end

      # @private
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
        klass.prepend(Initializer)
      end

      # Initializer method for classes that have Configurable mixed in
      module Initializer
        # Make sure this class has a default @config ready to use
        def initialize(*args)
          @config = initialize_default_config
          super
        end
      end

      # Instance methods for classes that have Configurable mixed in
      module InstanceMethods
        attr_reader :config

        # Take given options and apply them to this class's settings
        # and make them available in @config and validates that they
        # conform to setting rules
        def apply_options(options)
          options.transform_keys!(&:to_sym)

          options.each do |name, value|
            setting = self.class.all_settings[name]

            # Do nothing with a given option if it's not a connector setting
            next unless setting

            @config[name] = coerced_value(setting, name, value)
          end
          validate_config
          options
        end

        # Name of all settings available to this class
        def self.settings
          self.class.all_settings.keys
        end

        private

        def initialize_default_config
          self.class.config_with_defaults
        end

        def validate_config
          missing = (self.class.all_required_settings.keys - @config.compacted_h.keys)
          raise Chronicle::ETL::ConnectorConfigurationError, "Missing options: #{missing}" if missing.count.positive?
        end

        def coerced_value(setting, name, value)
          setting.type ? __send__("coerce_#{setting.type}", value) : value
        rescue StandardError
          raise(
            Chronicle::ETL::ConnectorConfigurationError,
            "Could not convert value '#{value}' into a #{setting.type} for setting '#{name}'"
          )
        end

        def coerce_hash(value)
          value.is_a?(Hash) ? value : {}
        end

        def coerce_string(value)
          value.to_s
        end

        # TODO: think about whether to split up float, integer
        def coerce_numeric(value)
          value.to_f
        end

        def coerce_boolean(value)
          if value.is_a?(String)
            value.downcase == "true"
          else
            value
          end
        end

        def coerce_array(value)
          value.is_a?(Array) ? value : [value]
        end

        def coerce_time(value)
          # parsing yml files might result in us getting Date objects
          # we convert to DateTime first to to ensure UTC
          return value.to_datetime.to_time if value.is_a?(Date)

          return value unless value.is_a?(String)

          # Hacky check for duration strings like "60m"
          if value.match(/[a-z]+/)
            ChronicDuration.raise_exceptions = true
            duration_ago = ChronicDuration.parse(value)
            Time.now - duration_ago
          else
            Time.parse(value)
          end
        end
      end

      # Class methods for classes that have Configurable mixed in
      module ClassMethods
        # Macro for creating a setting on a class {::Chronicle::ETL::Configurable}
        #
        # @param [String] name Name of the setting
        # @param [Boolean] required whether setting is required
        # @param [Object] default Default value
        # @param [Symbol] type Type
        #
        # @example Basic usage
        #   setting :when, type: :date, required: true
        #
        # @see ::Chronicle::ETL::Configurable
        def setting(name, default: nil, required: false, type: nil, description: nil)
          s = Setting.new(default, required, type, description)
          settings[name] = s
        end

        # Collect all settings defined on this class and its ancestors (that
        # have Configurable mixin included)
        def all_settings
          if superclass.include?(Chronicle::ETL::Configurable)
            superclass.all_settings.merge(settings)
          else
            settings
          end
        end

        # Filters settings to those that are required.
        def all_required_settings
          all_settings.select { |_name, setting| setting.required } || {}
        end

        def settings
          @settings ||= {}
        end

        def setting_exists?(name)
          all_settings.keys.include? name
        end

        def config_with_defaults
          s = all_settings.transform_values(&:default)
          Config.new(s)
        end
      end
    end
  end
end
