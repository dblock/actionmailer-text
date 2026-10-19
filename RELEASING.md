# Releasing ActionMailer::Text

Release bug fixes frequently, features less frequently, and breaking changes deliberately. This guide follows the release workflow used by [Danger-Toc](https://github.com/dblock/danger-toc/blob/master/RELEASING.md) and [Ruby-Enum](https://github.com/dblock/ruby-enum/blob/master/RELEASING.md).

## Prerequisites

You need push access to this repository and permission to publish `actionmailer-text` on RubyGems.org. Configure RubyGems authentication with MFA enabled; the gemspec requires MFA for publishing. Never commit credentials or OTP codes.

Use a Ruby version compatible with the default Rails version in Gemfile. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and testing other Rails versions.

## Prepare the Release

Start from an up-to-date `master` with a clean working tree.

```sh
git checkout master
git pull --ff-only origin master
git status --short
bundle install
bundle exec rake
```

Check that [GitHub Actions](https://github.com/dblock/actionmailer-text/actions/workflows/ci.yml) passes for the release commit across the entire Ruby/Rails matrix, including lint.

Confirm the version in [lib/actionmailer-text/version.rb](lib/actionmailer-text/version.rb) matches the upcoming heading in [CHANGELOG.md](CHANGELOG.md). Follow [Semantic Versioning](https://semver.org/): use patch releases for backward-compatible fixes, minor releases for backward-compatible features, and major releases for incompatible changes. During the initial `0.x` series, use a minor version increment for breaking changes and describe them explicitly.

Replace `Next` with the release date using the changelog's `YYYY-MM-DD` format, and remove `Your contribution here.` from that release section. For example:

```markdown
### 0.2.0 (2026-10-19)
```

Review changelog entries, linked PRs, and compatibility requirements. Submit the preparation changes in a PR and merge it before publishing. Include the version file if its value needs to change.

```sh
git checkout -b release/0.2.0
git add CHANGELOG.md lib/actionmailer-text/version.rb
git commit -m "Prepare release 0.2.0"
git push -u origin release/0.2.0
```

After the PR is merged, update `master` again and confirm its CI is green. Build the gem and inspect its contents before publishing:

```sh
git checkout master
git pull --ff-only origin master
bundle exec rake build
tar -xOf pkg/actionmailer-text-0.2.0.gem data.tar.gz | tar -tzf -
```

The package should contain the library and published documentation, not specs, credentials, or local artifacts. Substitute the intended version for `0.2.0` throughout these commands.

## Publish

From the clean release commit on `master`, run Bundler's release task:

```sh
bundle exec rake release
```

This builds the gem, creates the `v0.2.0` tag, pushes the commit/tag, and publishes the package to RubyGems.org. Complete the authentication or MFA prompt as requested.

If publishing fails after the tag has been pushed, inspect the output and check whether the version already exists on RubyGems.org before retrying. Do not recreate or move the published tag. If only the RubyGems upload failed, push the already-built package directly:

```sh
gem push pkg/actionmailer-text-0.2.0.gem
```

Complete MFA when prompted. Do not rerun the whole release task blindly: tagging and publishing can succeed independently, and published gem versions cannot be overwritten.

Verify the version appears on [RubyGems.org](https://rubygems.org/gems/actionmailer-text) and the tag points to the intended release commit:

```sh
gem list --remote --exact actionmailer-text
git ls-remote --tags origin 'v0.2.0*'
```

Create a [GitHub release](https://github.com/dblock/actionmailer-text/releases) from the existing tag, using the corresponding changelog section as release notes. This does not replace publishing the gem to RubyGems.org.

## Prepare the Next Development Version

Increment the patch version in `lib/actionmailer-text/version.rb` and add a new section at the top of CHANGELOG.md:

```markdown
### 0.2.1 (Next)

* Your contribution here.
```

Submit these changes in a separate PR:

```sh
git checkout -b chore/prepare-0.2.1
git add CHANGELOG.md lib/actionmailer-text/version.rb
git commit -m "Prepare next development version 0.2.1"
git push -u origin chore/prepare-0.2.1
```
