# BacktraceCleaner

[![Gem Version](https://badge.fury.io/rb/backtrace_cleaner.svg)](https://badge.fury.io/rb/backtrace_cleaner)

This is an extraction of ActiveSupport's [BacktraceCleaner](https://api.rubyonrails.org/classes/ActiveSupport/BacktraceCleaner.html) library.

This gem exists for everyone who needs this ActiveSupport's feature without the rest of ActiveSupport.

You can find original [source code](https://github.com/rails/rails/blob/dd8d37881c936d22acbc244e7e3b9b3a26e441b8/activesupport/lib/active_support/backtrace_cleaner.rb) on GitHub.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'backtrace_cleaner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backtrace_cleaner

## Usage

```ruby
bc = BacktraceCleaner.new
bc.add_filter   { |line| line.gsub(Rails.root.to_s, '') } # strip the Rails.root prefix
bc.add_silencer { |line| line =~ /puma|rubygems/ } # skip any lines from puma or rubygems
bc.clean(exception.backtrace) # perform the cleanup
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Morozzzko/backtrace_cleaner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BacktraceCleaner project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/backtrace_cleaner/blob/master/CODE_OF_CONDUCT.md).
