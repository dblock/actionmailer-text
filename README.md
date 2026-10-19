ActionMailer::Text
==================

[![CI](https://github.com/dblock/actionmailer-text/actions/workflows/ci.yml/badge.svg)](https://github.com/dblock/actionmailer-text/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/actionmailer-text.svg)](http://badge.fury.io/rb/actionmailer-text)

Automatically insert a text/plain part into your HTML multipart e-mails.

## Installation

Requires Ruby 3.1 or newer. Use a Ruby version supported by your selected Rails release.

```ruby
gem 'actionmailer-text'
```

## Usage

```ruby
class WelcomeMailer < ActionMailer::Base
  include ActionMailer::Text

  default from: 'welcome@example.org'

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome!') do |format|
      format.html { render 'welcome' }
    end
  end
end

```

### Selecting actions

Including `ActionMailer::Text` generates plaintext for every action by default. To limit generation to specific actions, declare `generate_text` in your mailer:

```ruby
class WelcomeMailer < ActionMailer::Base
  include ActionMailer::Text

  generate_text only: [:welcome]
end
```

Use `generate_text except: [:receipt]` to generate plaintext for every action except those listed. Action names accept strings or symbols, individually or in arrays. Use either `only:` or `except:`, not both. An empty `only: []` disables generation for all actions; an empty `except: []` excludes none.

Filters are inherited by subclasses. A subclass can replace the inherited filter with its own `generate_text` declaration, or call `generate_text` without arguments to restore generation for every action. Filtering only controls automatic generation: explicitly rendered text parts are always preserved.

## Details

The MIME standard allows systems to send e-mail with multiple parts: plain/text for business-efficient devices such as the Blackberry, and text/html for web-based e-mail readers, such as GMail. Furthermore, ActionMailer supports multiple template formats: create an .html.haml template along with a .txt.haml template to generate both. We also know that text/plain email helps deliverability, but we believe a disproportionately small amount of text e-mails are actually read - the vast majority of devices are capable of parsing some HTML. This gem lets you get the text/plain part for free.

HTML is parsed with Nokogiri. Generated text preserves repeated content, includes image alt text and link destinations, and formats headings, lists, paragraphs, and line breaks. Existing explicit text parts are left unchanged.

Escaped markup remains literal text, image alt text does not require a self-closing tag, comments and script/style content are omitted, and malformed HTML is repaired before conversion. Fragment text surrounding paragraphs may gain paragraph breaks as Nokogiri normalizes the document. Nested list items appear on separate lines; ordered lists use `*` bullets, and nesting is flattened rather than indented.

See [this blog post](http://artsy.github.io/blog/2012/05/16/generating-automatic-plain-text-mime-parts-with-rails-actionmailer) for details.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright and License

Copyright (c) 2015, Daniel Doubrovkine, Artsy and [Contributors](CHANGELOG.md).

This project is licensed under the [MIT License](LICENSE.md).
