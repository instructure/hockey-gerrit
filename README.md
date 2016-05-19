# hockey-gerrit

[![Gem Version](https://badge.fury.io/rb/hockey-gerrit.svg)](https://rubygems.org/gems/hockey-gerrit)
[![Build Status](https://travis-ci.org/instructure/hockey-gerrit.svg?branch=master)](https://travis-ci.org/instructure/hockey-gerrit)
[![Code Climate](https://codeclimate.com/github/instructure/hockey-gerrit/badges/gpa.svg)](https://codeclimate.com/github/instructure/hockey-gerrit)
[![Coverage Status](https://coveralls.io/repos/github/instructure/hockey-gerrit/badge.svg?branch=HEAD)](https://coveralls.io/github/instructure/hockey-gerrit?branch=HEAD)
[![Dependency Status](https://gemnasium.com/badges/github.com/instructure/hockey-gerrit.svg)](https://gemnasium.com/github.com/instructure/hockey-gerrit)

The hockey-gerrit gem saves the gerrit change number, patch number, commit message and author to a file.
The file can then be used with hockeyapp's Jenkins plugin to publish release notes for a mobile app.

## Installation

```
gem install hockey-gerrit
```

## Usage

Run hockey-gerrit inside a Jenkins job's execute shell. The job must be triggered by the gerrit-trigger plugin.

## Test

This project uses [Rubocop](https://github.com/bbatsov/rubocop) for linting
and [RSpec](https://github.com/rspec/rspec) for testing.
Run `rake` to run tests.

### Test Usage

1. Inside of a git repo, run `hockey-gerrit`.
2. Export a temporary environment variable for `GERRIT_REFSPEC`.
    * (eg. `export GERRIT_REFSPEC="this/is/a/test"`
3. The output will be something similar to the following: (Writes to `changelog.md`)

```
g70000,10
John Doe: Made a cool commit
```
