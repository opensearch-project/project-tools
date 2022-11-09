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
  end
end
