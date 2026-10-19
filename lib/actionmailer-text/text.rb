# frozen_string_literal: true

module ActionMailer
  # Adds a generated plaintext alternative to HTML mail unless an explicit text part exists.
  module Text
    def self.included(klass)
      klass.class_eval do
        include ActionMailer::Text::HtmlToPlainText

        class_attribute :text_generation_filter, instance_writer: false
        extend ClassMethods
      end
    end

    # Configures inherited action filters for automatic plaintext generation.
    module ClassMethods
      def generate_text(only: nil, except: nil)
        raise ArgumentError, 'Specify only or except, not both' unless only.nil? || except.nil?

        self.text_generation_filter = {
          only: normalize_text_actions(only),
          except: normalize_text_actions(except)
        }.freeze
      end

      private

      def normalize_text_actions(actions)
        return if actions.nil?

        Array(actions).map do |action|
          raise ArgumentError, 'Action names must be strings or symbols' unless action.is_a?(String) || action.is_a?(Symbol)

          action.to_s.dup.freeze
        end.freeze
      end
    end

    def collect_responses(headers)
      responses = super
      return responses unless generate_text_for_action?

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

    private

    def generate_text_for_action?
      filter = self.class.text_generation_filter
      return true unless filter
      return filter[:only].include?(action_name) if filter[:only]

      !filter[:except] || !filter[:except].include?(action_name)
    end
  end
end
