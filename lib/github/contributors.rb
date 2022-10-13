# frozen_string_literal: true

module GitHub
  class Contributors < Array
    extend GitHub::Data

    def initialize(arr)
      super(Contributor.wrap(arr))
    end

    def humans
      reject { |item| item.type == 'Bot' || GitHub::Data.bots.include?(item.to_s) }
    end

    def members
      buckets[:members]
    end

    def contractors
      buckets[:contractors]
    end

    def external
      buckets[:external]
    end

    def unknown
      buckets[:unknown]
    end

    def all
      humans
    end

    def all_members
      members.concat(contractors)
    end

    def all_external
      external
    end

    def all_external_percent
      ((all_external.size.to_f / all.size) * 100).to_i
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
