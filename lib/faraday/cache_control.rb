# frozen_string_literal: true

module Faraday
  class CacheControl < Faraday::Middleware
    def initialize(app, *_args)
      super(app)
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      response = @app.call(env)
      # force caching for a year
      response.headers['cache-control'] = 'public, max-age=31536000'
      response
    end
  end
end
