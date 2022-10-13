# frozen_string_literal: true

module GitHub
  module RateLimited
    def rate_limited(&_block)
      suspend_s = 5
      begin
        yield if block_given?
      rescue Octokit::TooManyRequests
        sleep suspend_s
        suspend_s = [suspend_s * 2, $github.rate_limit.resets_in + 1].min
        retry
      end
    end
  end
end
