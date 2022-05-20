# frozen_string_literal: true

module OneSignalRails
  ##
  # The One Signal Rails Extension class
  class Railtie < Rails::Railtie
    # Add the :onesignal delivery method to the ActionMailer framework
    initializer 'onesignal_rails.add_delivery_method', before: 'action_mailer.set_configs' do
      ActiveSupport.on_load(:action_mailer) do
        ActionMailer::Base.add_delivery_method(:onesignal, OneSignalRails::DeliveryMethod)
      end
    end
  end
end
