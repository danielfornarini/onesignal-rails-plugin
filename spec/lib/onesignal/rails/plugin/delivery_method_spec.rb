# frozen_string_literal: true

require_relative '../../../../spec_helper'
require 'mail'

module OneSignal
  module Rails
    module Plugin
      EMAIL_TEXT_BODY = 'I am a plain text body'
      EMAIL_HTML_BODY = 'I am an <b>HTML</b> body'
      ALT_APP_ID = '11111111-1111-1111-1111-111111111111'
      ALT_APP_KEY = 'ALT_APP_KEY'

      describe 'DeliveryMethod' do
        subject(:mailer) do
          DeliveryMethod.new(perform_send_request: false, return_response: true)
        end

        describe 'initializing' do
          it 'defaults return_response to false' do
            m = DeliveryMethod.new
            expect(m.settings[:return_response]).to eq(false)
          end

          it 'defaults perform_send_request to true' do
            m = DeliveryMethod.new
            expect(m.settings[:perform_send_request]).to eq(true)
          end

          it 'defaults app_id to nil' do
            m = DeliveryMethod.new
            expect(m.settings[:app_id]).to be_nil
          end

          it 'defaults app_key to nil' do
            m = DeliveryMethod.new
            expect(m.settings[:app_key]).to be_nil
          end

          it 'allows setting of return_response to true' do
            m = DeliveryMethod.new(return_response: true)
            expect(m.settings[:return_response]).to eq(true)
          end

          it 'allows setting of app_id to a value' do
            m = DeliveryMethod.new(app_id: ALT_APP_ID)
            expect(m.settings[:app_id]).to eq(ALT_APP_ID)
          end

          it 'allows setting of app_key to a value' do
            m = DeliveryMethod.new(app_key: ALT_APP_KEY)
            expect(m.settings[:app_key]).to eq(ALT_APP_KEY)
          end
        end

        describe '#deliver!' do
          let(:mail) do
            Mail.new(
              to: 'test@example.com',
              from: 'test@company.co',
              subject: 'Hello Test!'
            )
          end

          context 'when using initialization' do
            it 'returns mailer itself' do
              m = DeliveryMethod.new(perform_send_request: false)
              ret = m.deliver!(mail)
              expect(ret).to eq(m)
            end

            it 'captures app id in notification from configuration' do
              notification = mailer.deliver!(mail)
              expect(notification.app_id).to eq(APP_ID)
            end

            it 'uses app id from configuration when set' do
              m = DeliveryMethod.new(app_id: ALT_APP_ID, perform_send_request: false, return_response: true)
              notification = m.deliver!(mail)
              expect(notification.app_id).to eq(ALT_APP_ID)
            end
          end

          context 'when sending email to' do
            it 'supports single email address' do
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test@example.com']
            end
            it 'supports single email address with name' do
              mail.to = 'Test Person <test@example.com>'
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test@example.com']
            end
            it 'supports single email address with quoted name' do
              mail.to = '"Test Person" <test@example.com>'
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test@example.com']
            end
            it 'supports multiple email addresses' do
              mail.to = 'test1@example.com;test2@example.com'
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test1@example.com', 'test2@example.com']
            end
            it 'supports multiple email addresses with names' do
              mail.to = 'Test1 Person <test1@example.com>; Test2 Person <test2@example.com>'
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test1@example.com', 'test2@example.com']
            end
            it 'supports multiple email addresses with quoted names' do
              mail.to = '"Test1 Person" <test1@example.com>; "Test2 Person" <test2@example.com>'
              notification = mailer.deliver!(mail)
              expect(notification.include_email_tokens).to eq ['test1@example.com', 'test2@example.com']
            end
          end

          context 'when sending email from' do
            it 'supports not setting from' do
              mail.from = nil
              notification = mailer.deliver!(mail)
              expect(notification.email_from_address).to be_nil
              expect(notification.email_from_name).to be_nil
            end

            it 'supports email address' do
              notification = mailer.deliver!(mail)
              expect(notification.email_from_address).to eq('test@company.co')
              expect(notification.email_from_name).to be_nil
            end

            it 'supports email address with name' do
              mail.from = 'Test Person <test@company.co>'
              notification = mailer.deliver!(mail)
              expect(notification.email_from_address).to eq('test@company.co')
              expect(notification.email_from_name).to eq('Test Person')
            end

            it 'supports email address with quoted name' do
              mail.from = '"Test Person" <test@company.co>'
              notification = mailer.deliver!(mail)
              expect(notification.email_from_address).to eq('test@company.co')
              expect(notification.email_from_name).to eq('Test Person')
            end

            it 'ignores all but first email address' do
              mail.from = 'test1@company.co;test2@company.co'
              notification = mailer.deliver!(mail)
              expect(notification.email_from_address).to eq('test1@company.co')
            end
          end

          context 'when sending email subject' do
            it 'supports subject' do
              notification = mailer.deliver!(mail)
              expect(notification.email_subject).to eq('Hello Test!')
            end

            it 'fails if told not to provide subject but no template is used' do
              mail.subject = OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT
              expect do
                mailer.deliver!(mail)
              end.to raise_exception('Must specify template_id if setting subject to OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT!')
            end
          end

          context 'when sending email body' do
            it 'supports body with text/plain content' do
              mail.content_type = 'text/plain'
              mail.body = EMAIL_TEXT_BODY
              notification = mailer.deliver!(mail)
              expect(notification.email_body).to eq(EMAIL_TEXT_BODY)
            end

            it 'supports body with text/html content' do
              mail.content_type = 'text/html'
              mail.body = EMAIL_HTML_BODY
              notification = mailer.deliver!(mail)
              expect(notification.email_body).to eq(EMAIL_HTML_BODY)
            end

            it 'chooses text/html body with both text/html and text/plain content' do
              mail.content_type = 'multipart/mixed'
              mail.part do |p|
                p.html_part = Mail::Part.new do
                  content_type 'text/html'
                  body EMAIL_HTML_BODY
                end
                p.text_part = Mail::Part.new do
                  content_type 'text/plain'
                  body EMAIL_TEXT_BODY
                end
              end

              notification = mailer.deliver!(mail)
              expect(notification.email_body).to eq(EMAIL_HTML_BODY)
            end
          end

          context 'when sending email template' do
            before do
              mail['template_id'] = '1'
            end

            it 'sets template_id with value' do
              notification = mailer.deliver!(mail)
              expect(notification.template_id).to eq('1')
            end

            it 'sets subject if specified' do
              notification = mailer.deliver!(mail)
              expect(notification.email_subject).to eq('Hello Test!')
            end

            it 'ignores subject when told to not use it' do
              mail.subject = OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT
              notification = mailer.deliver!(mail)
              expect(notification.email_subject).to be_nil
            end

            it 'ignores body if specified' do
              mail.content_type = 'text/plain'
              mail.body = EMAIL_TEXT_BODY
              notification = mailer.deliver!(mail)
              expect(notification.email_body).to be_nil
            end
          end

          context 'when sending email to existing OneSignal users via extensions' do
            it 'supports include_external_user_ids' do
              mail['include_external_user_ids'] = %w[1 2 3]
              notification = mailer.deliver!(mail)
              expect(notification.include_external_user_ids).to eq(%w[1 2 3])
              expect(notification.channel_for_external_user_ids).to eq('email')
              expect(notification.include_email_tokens).to be_nil
            end

            it 'supports include_player_ids' do
              mail['include_player_ids'] = %w[1 2 3]
              notification = mailer.deliver!(mail)
              expect(notification.include_player_ids).to eq(%w[1 2 3])
              expect(notification.include_email_tokens).to be_nil
            end

            it 'supports included_segments' do
              mail['included_segments'] = %w[1 2 3]
              notification = mailer.deliver!(mail)
              expect(notification.included_segments).to eq(%w[1 2 3])
              expect(notification.include_email_tokens).to be_nil
            end

            it 'supports excluded_segments' do
              mail['excluded_segments'] = %w[1 2 3]
              notification = mailer.deliver!(mail)
              expect(notification.excluded_segments).to eq(%w[1 2 3])
              expect(notification.include_email_tokens).to be_nil
            end
          end

          context 'when sending email with custom_notification_args extensions' do
            # TODO: These properties exist in the API, but not in the Ruby client yet
            # it 'supports name' do
            #   mail['custom_notification_args'] = {'name' => 'Test'}
            #   notification = mailer.deliver!(mail)
            #   expect(notification.name).to eq("Test")
            # end
            # it 'supports disable_email_click_tracking' do
            #   mail['custom_notification_args'] = {'disable_email_click_tracking' => true}
            #   notification = mailer.deliver!(mail)
            #   expect(notification.disable_email_click_tracking).to eq(true)
            # end

            it 'supports external_id' do
              mail['custom_notification_args'] = { 'external_id' => 'Test' }
              notification = mailer.deliver!(mail)
              expect(notification.external_id).to eq('Test')
            end

            it 'supports send_after' do
              mail['custom_notification_args'] = { 'send_after' => 'Thu Sep 24 2015 14:00:00 GMT-0700 (PDT)' }
              notification = mailer.deliver!(mail)
              expect(notification.send_after).to eq('Thu Sep 24 2015 14:00:00 GMT-0700 (PDT)')
            end

            # NOTE: Though this is supported by the API, Email time of day is not currently supported by the backend
            it 'supports time of day delivery' do
              mail['custom_notification_args'] = { 'delayed_option' => 'timezone', 'delivery_time_of_day' => '9:00AM' }
              notification = mailer.deliver!(mail)
              expect(notification.delayed_option).to eq('timezone')
              expect(notification.delivery_time_of_day).to eq('9:00AM')
            end

            # NOTE: Though this is supported by the API, Email time of day is not currently supported by the backend
            it 'supports last active delivery' do
              mail['custom_notification_args'] = { 'delayed_option' => 'last-active' }
              notification = mailer.deliver!(mail)
              expect(notification.delayed_option).to eq('last-active')
            end

            it 'supports throttle_rate_per_minute' do
              mail['custom_notification_args'] = { 'throttle_rate_per_minute' => 4 }
              notification = mailer.deliver!(mail)
              expect(notification.throttle_rate_per_minute).to eq(4)
            end
          end
        end
      end
    end
  end
end
