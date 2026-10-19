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

describe 'ActionMailer::Text action filters' do
  let(:mailer) do
    Class.new(ActionMailer::Base) do
      include ActionMailer::Text

      default from: 'joe@example.org'

      def welcome
        mail(to: 'user@example.org', subject: 'Welcome') do |format|
          format.html { render html: '<p>Welcome</p>'.html_safe }
        end
      end

      alias_method :receipt, :welcome

      def explicit_parts
        mail(to: 'user@example.org', subject: 'Explicit') do |format|
          format.text { render plain: 'Handwritten text' }
          format.html { render html: '<p>HTML content</p>'.html_safe }
        end
      end
    end
  end

  it 'generates text for every action by default' do
    expect(mailer.welcome.message.text_part.body.decoded).to eq('Welcome')
    expect(mailer.receipt.message.text_part.body.decoded).to eq('Welcome')
  end

  it 'generates text only for selected actions' do
    mailer.generate_text only: :welcome

    expect(mailer.welcome.message.text_part.body.decoded).to eq('Welcome')
    expect(mailer.receipt.message.mime_type).to eq('text/html')
    expect(mailer.receipt.message.body.decoded).to eq('<p>Welcome</p>')
  end

  it 'excludes selected actions' do
    mailer.generate_text except: ['receipt']

    expect(mailer.welcome.message.text_part.body.decoded).to eq('Welcome')
    expect(mailer.receipt.message.mime_type).to eq('text/html')
  end

  it 'supports empty filters' do
    mailer.generate_text only: []
    expect(mailer.welcome.message.mime_type).to eq('text/html')

    mailer.generate_text except: []
    expect(mailer.welcome.message.text_part.body.decoded).to eq('Welcome')
  end

  it 'inherits filters and replaces them without changing the parent' do
    mailer.generate_text only: ['welcome']
    child = Class.new(mailer)
    expect(child.receipt.message.mime_type).to eq('text/html')

    child.generate_text only: [:receipt]
    expect(child.receipt.message.text_part.body.decoded).to eq('Welcome')
    expect(child.welcome.message.mime_type).to eq('text/html')
    expect(mailer.welcome.message.text_part.body.decoded).to eq('Welcome')
    expect(mailer.receipt.message.mime_type).to eq('text/html')

    child.generate_text
    expect(child.welcome.message.text_part.body.decoded).to eq('Welcome')
  end

  it 'preserves explicit text in excluded actions' do
    mailer.generate_text only: :welcome
    expect(mailer.explicit_parts.message.text_part.body.decoded).to eq('Handwritten text')
  end

  it 'rejects ambiguous filters and invalid action names' do
    expect { mailer.generate_text only: :welcome, except: :receipt }.to raise_error(ArgumentError, /not both/)
    expect { mailer.generate_text only: [123] }.to raise_error(ArgumentError, /strings or symbols/)
  end
end
