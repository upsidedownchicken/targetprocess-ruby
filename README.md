# Targetprocess

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/targetprocess`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'targetprocess'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install targetprocess

## Usage

### Authentication

Targetprocess uses `Basic` authentication that depends on environment variables you set. One way to do this (in bash) is to create a file that sets those variables and then source it.

In `.targetprocessrc`:

```bash
export targetprocess_base_uri="https://your-subdomain.tpondemand.com/api/v1/"
export targetprocess_username="your targetprocess username"
export targetprocess_password="your targetprocess password"
```

Then run `source .targetprocessrc` to make them available in the current session.

Once you've set these environment variables appropriately, you can use Targetprocess to view your data on the command line.

### UserStories

```
$ ./exe/targetprocess help stories
NAME
    stories - List stories

SYNOPSIS
    targetprocess [global options] stories [command options]

COMMAND OPTIONS
    --state=arg - State (default: none)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/targetprocess-ruby.

