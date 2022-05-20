# frozen_string_literal: true

require 'onesignal_rails/delivery_method'
require 'onesignal_rails/onesignal_deliveryerror'
require 'onesignal_rails/literals'
require 'onesignal_rails/railtie'
require 'onesignal_rails/version'

##
# This module contains all classes provided by the OneSignal Rails plugin.
module OneSignalRails
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
