# frozen_string_literal: true

require 'onesignal/rails/plugin/delivery_method'
require 'onesignal/rails/plugin/delivery_error'
require 'onesignal/rails/plugin/literals'
require 'onesignal/rails/plugin/railtie'
require 'onesignal/rails/plugin/version'

##
# This module contains all classes provided by the OneSignal Rails plugin.
module OneSignal
  module Rails
    class << self
      # This is required because other gems in the OneSignal module namespace
      # specifically use `Rails.logger` thinking they are picking up the
      # Rails logger. So we proxy that for them.
      def logger
        ::Rails.logger
      end
    end

    module Plugin
      class << self
        attr_writer :configuration
      end

      def self.configuration
        @configuration ||= Configuration.new
      end

      def self.configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end

      ##
      # Configuration options for the OneSignal plugin.
      class Configuration
        attr_accessor :app_key, :app_id

        def initialize
          set_defaults
        end

        def set_defaults
          @app_key = if ENV.key?('ONESIGNAL_APP_KEY')
                      ENV['ONESIGNAL_APP_KEY']
                    else
                      ''
                    end

          @app_id = if ENV.key?('ONESIGNAL_APP_ID')
                      ENV['ONESIGNAL_APP_ID']
                    else
                      ''
                    end
        end
      end
    end
  end
end
