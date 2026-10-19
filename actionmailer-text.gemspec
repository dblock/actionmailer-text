# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'actionmailer-text/version'

Gem::Specification.new do |s|
  s.name = 'actionmailer-text'
  s.version = ActionMailer::Text::VERSION
  s.authors = ['Daniel Doubrovkine']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 2.0'
  s.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.md', 'CHANGELOG.md']
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/dblock/actionmailer-text'
  s.licenses = ['MIT']
  s.summary = 'Automatically insert a text/plain part into your HTML multipart e-mails.'
  s.add_dependency 'actionmailer'
  s.add_dependency 'htmlentities'
  s.metadata['rubygems_mfa_required'] = 'true'
end
