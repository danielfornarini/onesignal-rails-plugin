# frozen_string_literal: true

# #OneSignal
#
# A powerful way to send personalized messages at scale and build effective customer
# engagement strategies. Learn more at onesignal.com.
#
# Contact: devrel@onesignal.com
#

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'onesignal_rails/version'

Gem::Specification.new do |s|
  s.name        = 'onesignal-rails'
  s.version     = OneSignalRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['OneSignal']
  s.email       = ['devrel@onesignal.com']
  s.homepage    = 'https://onesignal.com/'
  s.summary     = 'OneSignal for Rails'
  s.description = 'A custom Rails ActionMailer delivery method which will send emails through your OneSignal integration'
  s.license     = 'Modified MIT'
  s.required_ruby_version = '>= 2.5'

  s.add_dependency 'onesignal', '~> 1.0.0.beta1'
  s.add_dependency 'rails'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files         = `find *`.split("\n").uniq.sort.reject(&:empty?)
  s.test_files    = `find spec/*`.split("\n")
  s.executables   = []
  s.require_paths = ['lib']
end
