$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'actionmailer-text'
require 'email-example-spec'

ActionMailer::Base.view_paths = File.join(File.dirname(__FILE__), 'support')

EmailExampleSpec.configure do |config|
  config.fixture_path = File.join(File.dirname(__FILE__), 'support/fixtures')
end
