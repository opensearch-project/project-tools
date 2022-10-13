# frozen_string_literal: true

module GitHub
  class User < SimpleDelegator
    extend GitHub::RateLimited
    include Comparable

    def initialize(username)
      super $github.user(username)
    rescue Octokit::NotFound => e
      raise "Invalid user: #{username}: #{e.message}"
    end

    def <=>(other)
      to_s <=> other.to_s
    end

    def eql?(other)
      to_s.eql?(other.to_s)
    end

    def hash
      to_s.hash
    end

    def to_s
      login
    end

    def member?
      [company, bio].compact.each do |field|
        field.split(%r{[\s/]}).map(&:downcase).each do |co|
          return true if GitHub::Data.companies.include?(co)
        end
      end
      false
    end

    def self.wrap(collection)
      pb = ProgressBar.create(total: collection.size, title: 'Fetching users ...')
      result = []
      rate_limited do
        collection.each do |obj|
          result.push(new(obj))
          pb.increment
        end
      end
      pb.finish
      result
    end
  end
end
