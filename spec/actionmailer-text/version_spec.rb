require 'spec_helper'

describe ActionMailer::Text do
  it 'has a version' do
    expect(ActionMailer::Text::VERSION).to_not be nil
  end
end
