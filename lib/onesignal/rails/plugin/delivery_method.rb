# frozen_string_literal: true

require 'onesignal'

module OneSignal
  module Rails
    module Plugin
      ##
      # Provides the ActionMailer delivery method of :onesignal.  When this delivery method is used,
      # mail sent by an ActionMailer is sent to OneSignal through an email notification.  Alternatively
      # or in addition to the standard mail funcitonality, additional OneSignal specific parameters
      # can be specified to take advantage of OneSignal specific functionality.
      class DeliveryMethod
        DEFAULTS = {
          perform_send_request: true,
          return_response: false,
          app_key: nil,
          app_id: nil
        }.freeze

        attr_accessor :settings

        def initialize(settings = {})
          self.settings = DEFAULTS.merge(settings)
        end

        def deliver!(mail)
          validate(mail)

          notification = OneSignal::Notification.new({ app_id: settings[:app_id] || OneSignal::Rails::Plugin.configuration.app_id,
                                                      is_ios: false })

          add_from(notification, mail)
          add_to(notification, mail)
          add_subject(notification, mail)
          add_body(notification, mail)
          add_custom_notification_args(notification, mail)

          response = if settings[:perform_send_request] == false
                      notification
                    else
                      send notification
                    end

          settings[:return_response] ? response : self
        end

        private

        def validate(mail)
          # subject cannot be USE_TEMPLATE_SUBJECT unless template_id is specified (templates provide the subject)
          if (mail.subject == USE_TEMPLATE_SUBJECT) && !mail['template_id']
            raise 'Must specify template_id if setting subject to OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT!'
          end
        end

        def add_from(notification, mail)
          from_email = first_email(mail.from)

          notification.email_from_address = from_email.address if from_email&.address
          notification.email_from_name = from_email.display_name || from_email.name if from_email&.address
        end

        def add_to(notification, mail)
          # a specified "to override" takes priority over any "to" provided within the mail input
          if does_override_to(mail)
            if mail['include_external_user_ids']
              notification.include_external_user_ids = mail['include_external_user_ids'].value.split(',').map(&:strip)
              notification.channel_for_external_user_ids = 'email'
            end
            if mail['include_player_ids']
              notification.include_player_ids = mail['include_player_ids'].value.split(',').map(&:strip)
            end
            if mail['included_segments']
              notification.included_segments = mail['included_segments'].value.split(',').map(&:strip)
            end
            if mail['excluded_segments']
              notification.excluded_segments = mail['excluded_segments'].value.split(',').map(&:strip)
            end
          else
            notification.include_email_tokens = mail.to
          end
        end

        def does_override_to(mail)
          mail['include_external_user_ids'] ||
            mail['include_player_ids'] ||
            mail['included_segments'] ||
            mail['excluded_segments']
        end

        def add_subject(notification, mail)
          notification.email_subject = mail.subject if mail.subject != USE_TEMPLATE_SUBJECT
        end

        def add_body(notification, mail)
          # a specified template takes priority over any body provided within the mail
          if mail['template_id']
            notification.template_id = mail['template_id'].value
            raise mail['custom_data'].inspect
            notification.custom_data = mail['custom_data'].unparsed_value if mail['custom_data']
          else
            case mail.mime_type
            when 'text/plain', 'text/html'
              notification.email_body = mail.body.decoded
            when 'multipart/alternative', 'multipart/mixed', 'multipart/related'
              # for multipart, the html will always win if it exists
              notification.email_body = mail.text_part.decoded if mail.text_part
              notification.email_body = mail.html_part.decoded if mail.html_part
            end
          end
        end

        def add_custom_notification_args(notification, mail)
          input = mail['custom_notification_args']
          if input.is_a?(Mail::Field)
            input.unparsed_value.each do |key, value|
              notification.send("#{key}=", value)
            end
          elsif input.respond_to?('each')
            input.each do |item|
              item.unparsed_value.each do |key, value|
                notification.send("#{key}=", value)
              end
            end
          elsif input
            raise DeliveryError, "Unknown type for customer_notification_args: #{input.class.name}"
          end
        end

        def first_email(input)
          convert_emails(input).first
        end

        def convert_emails(input)
          if input.is_a?(String)
            [Mail::Address.new(input)]
          elsif input.is_a?(::Mail::AddressContainer) && !input.instance_variable_get('@field').nil?
            input.instance_variable_get('@field').addrs.map # Already Mail::Address
          elsif input.is_a?(::Mail::AddressContainer)
            input.map do |addr|
              Mail::Address.new(addr)
            end
          elsif input.is_a?(::Mail::StructuredField)
            [Mail::Address.new(input.value)]
          elsif input.nil?
            []
          else
            raise OneSignalDeliveryError, "Unknown type for email: #{input.class.name}"
          end
        end

        def client
          # we create our own configuration in case the OneSignal library is used outside of the
          # ActionMailer context, with different options
          config = OneSignal::Configuration.new
          config.configure do |c|
            c.app_key = settings[:app_key] || OneSignal::Rails::Plugin.configuration.app_key
          end

          OneSignal::DefaultApi.new(OneSignal::ApiClient.new(config))
        end

        def send(notification)
          response = client.create_notification(notification)

          raise DeliveryError.new('OneSignal request responded with errors', response) if response.errors
        end
      end
    end
  end
end
