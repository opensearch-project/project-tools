# frozen_string_literal: true

module GitHub
  class Contributor < Item
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
  end
end
