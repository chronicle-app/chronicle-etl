# frozen_string_literal: true

require "ostruct"

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
      Setting = Struct.new(:default, :required, :type)
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
            raise(Chronicle::ETL::ConfigurationError, "Unrecognized setting: #{name}") unless setting

            @config[name] = coerced_value(setting, value)
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
          raise Chronicle::ETL::ConfigurationError, "Missing options: #{missing}" if missing.count.positive?
        end

        def coerced_value(setting, value)
          setting.type ? __send__("coerce_#{setting.type}", value) : value
        end

        def coerce_string(value)
          value.to_s
        end

        def coerce_time(value)
          # TODO: handle durations like '3h'
          if value.is_a?(String)
            Time.parse(value)
          else
            value
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
        def setting(name, default: nil, required: false, type: nil)
          s = Setting.new(default, required, type)
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
