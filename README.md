[![Build Status](https://travis-ci.org/IndraGunawan/rubyq.svg?branch=master)](https://travis-ci.org/IndraGunawan/rubyq)

# Rubyq

This library is for building simple query strings via an object oriented

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubyq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubyq

## Usage

```ruby
require 'rubyq'

query_builder = Rubyq::QueryBuilder.new

# Select
query_builder.select('id').from('my_table').where('id = 1')
# will output: SELECT id FROM my_table WHERE id = 1

# Update
query_builder.update('my_table').set('name', 'newname').where('id = 1')
# will output: UPDATE my_table SET name = 'newname' WHERE id = 1

# Delete
query_builder.delete('my_table').where('id = 1')
# will output: DELETE my_table WHERE id = 1
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/IndraGunawan/rubyq.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
