<h1 align="center">Welcome to the official OneSignal Ruby on Rails Plugin 👋</h1>

[![Gem Version][rgb]][rgl]

<p>
  <a href="https://github.com/OneSignal/onesignal-rails-plugin/blob/master/README.md" target="_blank">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" />
  </a>
  <a href="https://github.com/OneSignal/onesignal-rails-plugin/graphs/commit-activity" target="_blank">
    <img alt="Maintenance" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" />
  </a>
  <a href="https://twitter.com/onesignal" target="_blank">
    <img alt="Twitter: onesignal" src="https://img.shields.io/twitter/follow/onesignal.svg?style=social" />
  </a>
</p>

OneSignal - the Ruby on Rails gem for OneSignal

A powerful way to send personalized messages at scale and build effective customer engagement strategies. Learn more at onesignal.com

This gem provides OneSignal integration via the Ruby on Rails ActionMailer. A custom delivery method `:onesignal` can be used to direct
your Action Mailers to send emails through the OneSignal API.  Additional extensions to the mail functionality are provided to take
advantage of OneSignal's customer engagement platform! 

### 🖤 [RubyGems](https://rubygems.org/gems/onesignal-rails-plugin)

## 🚧 In Beta 🚧

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'onesignal-rails-plugin', '~> 1.0.0.beta1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onesignal-rails-plugin -pre

Or install from Github:

    $ gem "onesignal-rails-plugin", '~> 1.0.0.beta1', git: 'git://github.com/OneSignal/onesignal-rails-plugin.git'


## Configuration

To change all action mailers to target the OneSignal integration, edit `config/application.app` or `config/environments/$ENVIRONMENT.rb` and 
add/change the following to the ActionMailer configuration

```ruby
config.action_mailer.delivery_method = :onesignal
```

Alternatively a specific ActionMailer can be configured to use the OneSignal delivery method.  Within your ActionMailer

```ruby
class MyOneSignalActionMailer < ActionMailer::Base
  self.delivery_method = :onesignal  

  def some_email(params)
    mail(...)
  end
end
```

The OneSignal-specific configuration information can be set in either environment variables or more dynamically via code. To access your app ID
and REST API key, please view the [documentation](https://documentation.onesignal.com/docs/accounts-and-keys).

Choose one of the following ways to provide your OneSignal-specific configuration:
1. [Using Environment Variables](#Using Environment Variables)
2. [Using Application Configuration](#Using Application Configuration)
3. [Using ActionMailer Configuration](#Using ActionMailer Configuration)

### Using Environment Variables
Ensure the OneSignal environment variables have been set, the `OneSignal::Rails::Plugin` module will pick these up automatically
```
ONESIGNAL_APP_KEY = 'your-app-key'
ONESIGNAL_APP_ID = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
```

### Using Application Configuration
The `OneSignal::Rails::Plugin` module can be configured in code by creating initializer file `config/initializers/onesignal_rails_plugin.rb` and adding the following
(Warning: for security purposes, REST API keys should not be hardcoded into your application)

```ruby
OneSignal::Rails::Plugin.configure do |c|
  c.app_key = 'your-app-key'
  c.app_id = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
end
```

### Using ActionMailer Configuration
For more granular and dynamic control, you can also configure as part of the ActionMailer configuration.  Edit `config/application.app` or
`config/environments/$ENVIRONMENT.rb` and add the following to the ActionMailer configuration (Warning: for security purposes, REST API keys should not
be hardcoded into your application)

```ruby
config.action_mailer.onesignal_settings = {
      app_key = 'your-app-key',
      app_id = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
    }
```

Similar to how the `delivery_method` is configured, alternatively a specific ActionMailer can be configured to have a more granular configuration.  Within your
ActionMailer add the following (Warning: for security purposes, REST API keys should not be hardcoded into your application)

```ruby
class MyOneSignalActionMailer < ActionMailer::Base
  self.delivery_method = :onesignal
  self.onesignal_settings = {
      app_key = 'your-app-key',
      app_id = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
    }

  def some_email(params)
    mail(...)
  end
end
```

## Usage
If the purpose of the ActionMailer is to generate a transactional email where the recipient, subject, and body are specified within the application,
no additional changes are required. Your existing ActionMailers will now send emails through your OneSignal integration!

## OneSignal Extensions
The mail functionality is extended to include additional attributes provided by the OneSignal API.  These attributes should be specified within your
ActionMailer through the `mail` invocation.  See [Examples](#Examples) for examples of how to invoke `mail` to exploit these extensions.

### template_id (string)
Specifies the id of a template created within OneSignal that should be used, rather than the body provided by your application (either via the `body`
parameter, or defined within the view of the ActionMailer). To use the subject within the template, specify a `OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT` within
the `subject` parameter.  If the `subject` parameter is set to anything else, it will be used as the subject of the email, overriding the subject within the template. 

### include_external_user_ids (string array)
A string array that lists the OneSignal external IDs that are to be the recipients of the email being sent, rather than the information provided by your application via the `to` parameter.

### include_player_ids (string array)
A string array that lists the OneSignal player IDs that are to be the recipients of the email being sent, rather than the information provided by your application via the `to` parameter.

### included_segments (string array)
A string array that lists the OneSignal segments that are to be the recipients of the email being sent, rather than the information provided by your application via the `to` parameter.

### excluded_segments (string array)
A string array that lists the OneSignal segments that will not be the recipients of the email being sent (all others will), rather than the information provided by your application via the `to` parameter.

### custom_notification_args (object)
An object that allows for customizing the email notification that will be sent.  Each property key and value of the object will be copied into the payload of the create notification operation.
This allows for greater customization of notification being sent.  Example of parameters that would most likely be specified within this object:
- *external_id:* Correlation and idempotency key.
- *send_after:* Schedule the message for future delivery.
- *throttle_rate_per_minute:* throttle delivery of the notification, either because throttling is not enabled at the application level or to override the application level throttling settings.

Note the following are not currently supported by the Ruby API library.
- *name:* identifier for tracking this message within the OneSignal dashboard or export analytics, not shown to the end user.
- *disable_email_click_tracking:* When true the URLs in the email will not change to link tracking URLs and will stay the same as originally set. Best used for emails containing Universal Links.  Defaults to false.

Note the following are not currently supported by the API backend.
- *delayed_option:* Can be `timezone` or `last-active`.
- *delivery_time_of_day:* when delayed_option=timezone, this is the time of day to deliver within the timezone.

## Examples

The following shows examples of how to invoke the `mail` function within your ActionMailer when integrated with OneSignal. Note the body is not specified as it is assumed to be generated through the view associated
to the ActionMailer.  This is not an exhaustive list, and different examples could be combined depending on your specific scenario.

```ruby
# Send a transactional email to a specific recipient (standard ActionMailer usage) 
mail(subject: "email example", from: 'no-reply@company.com', to: 'user@company.co')

# Send a transactional email, relying on the OneSignal default 'from' address specified within the OneSignal dashboard
mail(subject: "use OneSignal default from address example", to: 'user@company.co')

# Send an email using a OneSignal template as both the subject and body of the email
mail(subject: OneSignal::Rails::Plugin::USE_TEMPLATE_SUBJECT, to: 'user@company.co', template_id: '00000000-0000-0000-0000-000000000000')

# Send an email using a OneSignal template, overriding the subject specified on the template
mail(subject: "template subject override example", to: 'user@company.co', template_id: '00000000-0000-0000-0000-000000000000')

# Send an email to a list of OneSignal users via their external user IDs
mail(subject: "external id example", include_external_user_ids: ["User123", "User456"])

# Send an email to a list of OneSignal users via their player IDs
mail(subject: "player id example", include_player_ids: ["00000000-0000-0000-0000-000000000000", "11111111-1111-1111-1111-111111111111"])

# Send an email to a list of OneSignal users that are within the provided segments
mail(subject: "include segments example", included_segments: ["Subscribed Users"])

# Send an email to the app's audience, excluding the provided segments.
mail(subject: "excluded segments example", excluded_segments: ["Engaged Users"])

# Send an email with the external_id, which ensures idempotency
mail(subject: "set external_id example", to: 'user@company.co', custom_notification_args: { 'external_id' => "00000000-0000-0000-0000-000000000000" })

# Send an email after a certain time
mail(subject: "send after example", to: 'user@company.co', custom_notification_args: { 'send_after' => "2022-05-19 15:20:00 GMT-0400" })

# Send an email with rate throttling
mail(subject: "throttle rate example", to: 'user@company.co', custom_notification_args: { 'throttle_rate_per_minute' => 1 })
```

## Testing

To run the rspec tests

    $ bundle exec rspec --format documentation


## License

The gem is available as open source under the terms of the [MIT License][mit].

[rgb]: https://img.shields.io/gem/v/onesignal-rails-plugin.svg
[rgl]: https://rubygems.org/gems/onesignal-rails-plugin
[osa]: https://documentation.onesignal.com/reference/
[mit]: http://opensource.org/licenses/MIT

## Author

* Website: https://onesignal.com
* Twitter: [@onesignal](https://twitter.com/onesignal)
* Github: [@OneSignal](https://github.com/OneSignal)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/OneSignal/onesignal-rail-plugin/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2022 [OneSignal](https://github.com/OneSignal).<br />
This project is [MIT](https://opensource.org/licenses/MIT) licensed.
