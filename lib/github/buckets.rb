# frozen_string_literal: true

module GitHub
  module Buckets
    def members
      buckets[:members] || []
    end

    def contractors
      buckets[:contractors] || []
    end

    def external
      buckets[:external] || []
    end

    def unknown
      buckets[:unknown] || []
    end

    def all
      to_a
    end

    def all_members
      members.concat(contractors)
    end

    def all_external
      external
    end

    def all_external_percent
      return 0 unless all.any?

      ((all_external.size.to_f / all.size) * 100).to_i
    end

    def percent
      buckets.map do |k, v|
        pc = ((v.size.to_f / all.size) * 100).round(1)
        [k, pc]
      end.to_h
    end

    def self.bucket(username)
      if GitHub::Data.members.include?(username.to_s)
        :members
      elsif GitHub::Data.contractors.include?(username.to_s)
        :contractors
      elsif GitHub::Data.external_users.include?(username.to_s)
        :external
      else
        :unknown
      end
    end

    def [](bucket)
      buckets[bucket]
    end

    def buckets
      raise NotImplementedError, :buckets
    end
  end
end
