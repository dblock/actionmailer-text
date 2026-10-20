# frozen_string_literal: true

require 'spec_helper'
require 'bundler'
require 'open3'
require 'rbconfig'

describe ActionMailer::Text do
  it 'has a version' do
    expect(ActionMailer::Text::VERSION).to_not be nil
  end

  it 'loads the underscore entry point in a fresh Ruby process' do
    script = <<~RUBY
      require 'simplecov'
      SimpleCov.command_name 'underscore entry point'
      require 'logger'
      require 'actionmailer_text'
      abort 'Missing mailer integration' unless ActionMailer::Text.respond_to?(:included)
      abort 'Missing converter' unless ActionMailer::Text::HtmlToPlainText.convert_to_text('<p>Hello</p>') == 'Hello'
      abort 'Missing version' unless ActionMailer::Text::VERSION.match?(/\\A\\d+\\.\\d+\\.\\d+\\z/)
    RUBY
    gem_paths = (Gem.loaded_specs.values.map(&:base_dir) + Gem.path).uniq
    env = Bundler.unbundled_env.merge('GEM_PATH' => gem_paths.join(File::PATH_SEPARATOR))
    output, status = Open3.capture2e(env, RbConfig.ruby, '-Ilib', '-e', script, unsetenv_others: true)

    expect(status.success?).to be(true), output
  end
end
