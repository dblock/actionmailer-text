# frozen_string_literal: true

require 'spec_helper'

describe ActionMailer::Text do
  let(:mailer) do
    Class.new(ActionMailer::Base) do
      include ActionMailer::Text

      default from: 'Joe User <joe@example.org>'

      def welcome_mail(username)
        @username = username
        mail to: 'user@example.org', subject: 'Welcome!' do |format|
          format.html { render 'templates/welcome_email' }
        end
      end
    end
  end
  subject do
    mailer.welcome_mail('username')
  end
  it 'generates a text part' do
    expect(subject.parts.size).to eq 2
  end
  it 'inserts text part first' do
    expect(subject.parts.first.content_type).to eq 'text/plain; charset=UTF-8'
  end
  it 'inserts html part last' do
    expect(subject.parts.last.content_type).to eq 'text/html; charset=UTF-8'
  end
  it 'matches the multipart snapshot' do
    expect(subject).to match_email_example_in 'welcome_email.multipart'
  end
  it 'preserves rendered content and message headers' do
    expect(subject.text_part.body.decoded).to eq "Hi username,\n\nThanks for joining our service! Please check back often."
    expect(subject.html_part.body.decoded).to include '<p>Hi username,</p>'
    expect(subject.from).to eq ['joe@example.org']
    expect(subject.to).to eq ['user@example.org']
    expect(subject.subject).to eq 'Welcome!'
  end

  it 'preserves an explicitly rendered text part' do
    mailer.class_eval do
      def explicit_parts
        mail(to: 'user@example.org', subject: 'Explicit') do |format|
          format.text { render plain: 'Handwritten text' }
          format.html { render html: '<p>HTML content</p>'.html_safe }
        end
      end
    end

    message = mailer.explicit_parts.message
    expect(message.parts.size).to eq 2
    expect(message.text_part.body.decoded).to eq 'Handwritten text'
    expect(message.html_part.body.decoded).to eq '<p>HTML content</p>'
  end

  it 'leaves a text-only message unchanged' do
    mailer.class_eval do
      def text_only
        mail(to: 'user@example.org', subject: 'Text only') do |format|
          format.text { render plain: 'Only text' }
        end
      end
    end

    message = mailer.text_only.message
    expect(message).not_to be_multipart
    expect(message.body.decoded).to eq 'Only text'
  end

  it 'generates text without losing attachments' do
    mailer.class_eval do
      def with_attachment
        attachments['report.txt'] = 'Report contents'
        mail(to: 'user@example.org', subject: 'Attachment') do |format|
          format.html { render html: '<p>Attached report</p>'.html_safe }
        end
      end
    end

    message = mailer.with_attachment.message
    alternative = message.parts.find { |part| part.mime_type == 'multipart/alternative' }
    expect(alternative.parts.map(&:mime_type)).to eq ['text/plain', 'text/html']
    expect(alternative.parts.first.body.decoded).to eq 'Attached report'
    expect(message.attachments['report.txt'].body.decoded).to eq 'Report contents'
  end
end
