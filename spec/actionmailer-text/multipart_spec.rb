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
  it 'matches output' do
    expect(subject).to match_email_example_in 'welcome_email.multipart'
  end
end
