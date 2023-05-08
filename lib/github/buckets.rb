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

    def students
      buckets[:students] || []
    end

    def unknown
      buckets[:unknown] || []
    end

    def bots
      buckets[:bots] || []
    end

    def all
      to_a
    end

    def all_humans
      all.to_a - bots.to_a
    end

    def all_members
      members.to_a + contractors.to_a
    end

    def all_external
      external.to_a + students.to_a
    end

    def all_external_percent
      return 0 unless all.any?

      ((all_external.size.to_f / all_humans.size) * 100).to_i
    end

    def percent
      buckets.map do |k, v|
        pc = ((v.size.to_f / all_humans.size) * 100).round(1)
        [k, pc]
      end.to_h
    end

    def self.bucket(username)
      if GitHub::Data.members.include?(username.to_s)
        :members
      elsif GitHub::Data.contractors.include?(username.to_s)
        :contractors
      elsif GitHub::Data.college_contributors.include?(username.to_s)
        :students
      elsif GitHub::Data.external_users.include?(username.to_s)
        :external
      elsif GitHub::Data.bots.include?(username.to_s)
        :bots
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
