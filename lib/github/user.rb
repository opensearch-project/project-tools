# frozen_string_literal: true

module GitHub
  class User < Item
    include Comparable

    def initialize(id_or_obj)
      super(id_or_obj, :user)
    rescue Octokit::NotFound => e
      raise "Invalid user: #{id_or_obj}: #{e.message}"
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
  end
end
