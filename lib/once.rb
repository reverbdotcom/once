require "once/version"
require 'digest'

# Usage:
#
# 1. Connect to redis:
#    Once.redis = Redis.new(...)
#
# If you don't specify the redis connection, we will assume the presence of a $redis global
#
# 2. Use to wrap a call that you want done uniquely
#   Once.do(name: "sending_email", params: { email: "foo@bar.com" }, within: 1.hour) do
#     .. stuff that should happen only once ..
#   end
#
# The combination of the name and params makes the check unique. So typically it would be the
# command you're executing, plus the params to that command
module Once
  DEFAULT_TIME = 3600 # seconds

  class << self
    def redis
      @redis || $redis
    end

    def redis=(redis)
      @redis = redis
    end

    # Checks the given params to see if this is a unique string
    # If we've seen it within the expiry period (default: 1.hour),
    # then we will not execute the block
    #
    # name: The name of the check, used as a namespace
    # params: The params that will control whether or not the body executes
    def do(name:, params:, within: DEFAULT_TIME, &block)
      hash = Digest::MD5.hexdigest(params.inspect)
      redis_key = "uniquecheck:#{name}:#{hash}"

      if redis.set(redis_key, true, ex: within, nx: true)
        block.call
      end
    end

    def key_in_use?(name:, params:)
      ttl_seconds(name: name, params: params) > 0
    end

    def ttl_seconds(name:, params:)
      hash = Digest::MD5.hexdigest(params.inspect)
      redis_key = "uniquecheck:#{name}:#{hash}"

      redis.ttl(redis_key)
    end
  end
end
