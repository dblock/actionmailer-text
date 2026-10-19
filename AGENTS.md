# Agent Guide

ActionMailer::Text is a Ruby gem that generates a plaintext alternative for HTML Action Mailer messages. Read [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, commands, and contribution workflow.

Follow [RELEASING.md](RELEASING.md) for releases. Publishing gems and pushing release tags require an explicit release request; preparing documentation or bumping a development version is not authorization to publish.

## Code Layout

- `lib/actionmailer-text.rb` is the main entry point; `lib/actionmailer_text.rb` is its underscore alias.
- `lib/actionmailer-text/text.rb` integrates with Action Mailer's response collection.
- `lib/actionmailer-text/html_to_plain_text.rb` converts HTML into plaintext.
- `spec/actionmailer-text/` contains converter and mailer regression tests.
- `spec/support/` contains mailer templates and the multipart MIME snapshot.

## Changes and Validation

Preserve explicitly rendered text parts, text-only messages, MIME part ordering, and attachments. Add focused regression coverage when changing conversion or mailer behavior. Keep the multipart snapshot alongside behavioral assertions; inspect serialization differences rather than blindly regenerating it.

Use `bundle exec rake` to run lint and specs before committing. For focused work, use `bundle exec rspec spec/actionmailer-text/multipart_spec.rb` or `bundle exec rspec spec/actionmailer-text/html_to_plain_text_spec.rb`. See CONTRIBUTING.md for selecting Rails versions; `.github/workflows/ci.yml` defines the supported CI matrix.

Follow existing Ruby style and preserve the runtime compatibility declared in the gemspec. Do not raise the Ruby minimum solely to satisfy RuboCop's development target. Prefer fixing offenses over expanding `.rubocop_todo.yml`; apply safe autocorrections before regenerating the baseline.

Document public behavior in README.md and add a linked PR entry under the next release in CHANGELOG.md. Keep Markdown paragraphs on one line. The gem version lives in `lib/actionmailer-text/version.rb`; keep the next-release changelog heading aligned with it. Do not commit the ignored Gemfile.lock or generated gem packages.
