# frozen_string_literal: true

module ActionMailer
  # Adds a generated plaintext alternative to HTML mail unless an explicit text part exists.
  module Text
    def self.included(klass)
      klass.class_eval do
        include ActionMailer::Text::HtmlToPlainText
      end
    end

    def collect_responses(headers)
      responses = super
      html_part = responses.detect { |response| response[:content_type] == 'text/html' }
      text_part = responses.detect { |response| response[:content_type] == 'text/plain' }
      if html_part && !text_part
        responses.insert 0, content_type: 'text/plain', body: convert_to_text(html_part[:body], nil)
        unless headers[:parts_order].include?('text/plain')
          headers[:parts_order] =
            ['text/plain'] + headers[:parts_order]
        end
      end
      responses
    end
  end
end
