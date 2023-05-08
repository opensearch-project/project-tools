# frozen_string_literal: true

module GitHub
  class Contributors < Items
    extend GitHub::Data
    include GitHub::Buckets

    def initialize(arr)
      super arr, Contributor
    end

    def humans
      reject { |item| item.type == 'Bot' || GitHub::Data.bots.include?(item.to_s) }
    end

    def all
      humans
    end

    def self.bucket(username)
      if GitHub::Data.members.include?(username.to_s)
        :members
      elsif GitHub::Data.contractors.include?(username.to_s)
        :contractors
      elsif GitHub::Data.students.include?(username.to_s)
        :students
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
      @buckets ||= begin
        buckets = {}
        humans.each do |username|
          bucket = GitHub::Contributors.bucket(username.to_s)
          buckets[bucket] ||= {}
          buckets[bucket][username] ||= 0
          buckets[bucket][username] += 1
        end
        buckets
      end
    end
  end
end
