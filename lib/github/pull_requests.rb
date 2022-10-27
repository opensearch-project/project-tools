# frozen_string_literal: true

module GitHub
  class PullRequests < Items
    def initialize(arr_or_options)
      super arr_or_options, GitHub::PullRequest
    end

    def contributors
      @contributors ||= GitHub::Contributors.new(map(&:user))
    end

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
        each do |pr|
          next if pr.user.type == 'Bot'

          bucket = GitHub::Contributors.bucket(pr.user.login)
          buckets[bucket] ||= []
          buckets[bucket] << pr
        end
        buckets
      end
    end

    def page(options)
      data = $github.search_issues(query(options), per_page: 1000).items
      raise 'There are 1000+ PRs returned from a single query, reduce --page.' if data.size >= 1000

      data.reject do |pr|
        GitHub::Data.backports.any? { |b| pr.title&.downcase&.include?(b) }
      end
    end

    def query(options = {})
      GitHub::Searchables.new(options).to_a.concat(
        [
          'state:merged',
          'is:pull-request',
          'archived:false',
          'is:closed',
          "merged:#{options[:from]}..#{options[:to]}"
        ]
      ).compact.join(' ')
    end
  end
end
