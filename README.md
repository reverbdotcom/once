# Once

Executes a block of code only once within a specified timeframe. Uses Redis to ensure uniqueness.

## Installation

Add this line to your application's Gemfile:

    gem 'once'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install once

## Usage

First, connect to redis:

    Once.redis = Redis.new(...)

If you don't specify the redis connection, we will assume the presence of a $redis global

Now, use Once to wrap a call that you want done uniquely

    Once.do(name: "sending_email", params: { email: "foo@bar.com" }, within: 1.hour) do
      # executes once
    end

The combination of the name and params makes the check unique. So typically it would be the
command you're executing, plus the params to that command

## Notes

This does not implement an atomic lock, nor does it take into account
distributed locks across a cluster. This is more of a simple "probably
guarantee uniqueness" implementation used to guard against things happening
multiple times within minutes/hours/days, not milliseconds.

See: [redlock](https://github.com/antirez/redlock-rb) for an example of distributed locking.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
