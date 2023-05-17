# frozen_string_literal: true

module GitHub
  class Maintainers < Array
    include GitHub::Buckets

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

    def unique_count
      buckets.values.map(&:size).sum
    end

    def external_unique_count
      buckets[:external].size + buckets[:students].size
    end

    def each_pair(&_block)
      buckets.each_pair(&_block)
    end

    def [](bucket)
      buckets[bucket]
    end
  end
end
