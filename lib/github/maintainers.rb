# frozen_string_literal: true

module GitHub
  class Maintainers < Array
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

    def [](bucket)
      buckets[bucket] || []
    end

    def all
      to_a
    end

    def internal
      members.concat(contractors)
    end

    def all_external
      external
    end

    def all_external_percent
      return 0 unless all.any?

      ((all_external.size.to_f / all.size) * 100).to_i
    end

    def buckets
      @buckets ||= begin
        buckets = {}
        each do |user|
          bucket = GitHub::Contributors.bucket(user)
          buckets[bucket] ||= []
          buckets[bucket] << user
        end
        buckets
      end
    end
  end
end
