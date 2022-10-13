# frozen_string_literal: true

module GitHub
  class Contributor < SimpleDelegator
    include Comparable

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

    def self.wrap(collection)
      collection.map do |obj|
        new obj
      end
    end
  end
end
