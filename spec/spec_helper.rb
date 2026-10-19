# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 SimpleCov::Formatter::LcovFormatter
                                                               ])
SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
  track_files 'lib/**/*.rb'
end

require 'rspec'
require 'logger'
require 'actionmailer-text'
require 'email-example-spec'

ActionMailer::Base.view_paths = File.join(File.dirname(__FILE__), 'support')

EmailExampleSpec.configure do |config|
  config.fixture_path = File.join(File.dirname(__FILE__), 'support/fixtures')
end
