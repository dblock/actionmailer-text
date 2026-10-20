# Contributing to ActionMailer::Text

This project is work of [many contributors](https://github.com/dblock/actionmailer-text/graphs/contributors).

You're encouraged to submit [pull requests](https://github.com/dblock/actionmailer-text/pulls), [propose features and discuss issues](https://github.com/dblock/actionmailer-text/issues).

In the examples below, substitute your Github username for `contributor` in URLs.

## Fork the Project

Fork the [project on Github](https://github.com/dblock/actionmailer-text) and check out your copy.

```
git clone https://github.com/contributor/actionmailer-text.git
cd actionmailer-text
git remote add upstream https://github.com/dblock/actionmailer-text.git
```

## Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

## Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rake
```

The default Gemfile tests Rails 8.1. Select another supported Rails series with `RAILS_VERSION`, for example:

```sh
RAILS_VERSION='~> 7.2.0' bundle update
RAILS_VERSION='~> 7.2.0' bundle exec rspec
```

GitHub Actions runs the suite against Rails 6.1, 7.0, 7.1, 7.2, 8.0, and 8.1 with compatible Ruby versions, including Ruby 4.0 for Rails 8.1. Use a Ruby version supported by the selected Rails release. Lint runs separately with current RuboCop; `bundle exec rake` runs both lint and specs locally.

## Coverage

RSpec collects line and branch coverage with SimpleCov, including library files that were not loaded. Open `coverage/index.html` for the local report; `coverage/lcov.info` is generated for external reporting. The Coverage workflow uploads the reports as an artifact and submits LCOV to [Coveralls](https://coveralls.io/github/dblock/actionmailer-text). A maintainer must enable the repository in Coveralls for hosted reports to appear.

Coverage configuration lives in `.simplecov`. The entry-point regression runs in a fresh Ruby process and merges its coverage with RSpec, so the version file loaded early by Bundler is measured as well.

## Releasing

Maintainers should follow [RELEASING.md](RELEASING.md) to prepare, publish, and verify a release, then start the next development version.

## Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build.
Add to [spec](spec).

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

## Write Code

Implement your feature or bug fix.

Ruby style is enforced with [Rubocop](https://github.com/bbatsov/rubocop).
Run `bundle exec rubocop` and fix any style issues highlighted.

Make sure that `bundle exec rake` completes without errors.

## Write Documentation

Document any external behavior in the [README](README.md).

## Update Changelog

Add a line to [CHANGELOG](CHANGELOG.md) under *Next Release*.
Make it look like every other line, including your name and link to your Github account.

Danger runs `danger-changelog` on pull requests and reports missing changelog entries. Its read-only PR workflow creates a report; a separate workflow posts the report without checking out or executing PR code with write permissions. Both use the pinned [danger-pr-comment](https://github.com/numbata/danger-pr-comment) reusable workflows.

## Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

## Push

```
git push origin my-feature-branch
```

## Make a Pull Request

Go to https://github.com/contributor/actionmailer-text and select your feature branch.
Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

## Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

## Update CHANGELOG Again

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/dblock/actionmailer-text/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

## Check on Your Pull Request

Check the GitHub Actions results on your pull request and address any failures.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
