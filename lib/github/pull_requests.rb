# frozen_string_literal: true

module GitHub
  class PullRequests < Array
    extend GitHub::RateLimited
    extend GitHub::Progress

    attr_reader :org

    def initialize(org, options = {})
      @org = org
      super(PullRequests.fetch(org, options))
    end

    def contributors
      @contributors ||= GitHub::Contributors.new(map(&:user))
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

    def [](bucket)
      buckets[bucket]
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

    def self.fetch(org, options = {})
      all_contributions = []
      start_at = options[:from].is_a?(String) ? Date.parse(options[:from]) : options[:from]
      end_at = options[:to].is_a?(String) ? Date.parse(options[:to]) : options[:to]
      days = options[:page]
      raise ArgumentError('missing from') unless start_at
      raise ArgumentError('missing to') unless end_at
      raise ArgumentError('missing page') unless days

      progress(
        total: (((end_at - start_at) / days) + 1),
        title: "Fetching PRs between #{start_at} and #{end_at}"
      ) do |pb|
        current_date = start_at
        while current_date < end_at
          rate_limited do
            next_date = [current_date + days, end_at].min
            response = $github.search_issues(query(org, options.merge(from: current_date, to: next_date)), per_page: 1000)
            data = response.items
            raise "There are 1000+ PRs returned from a single query for #{days} day(s), reduce --page." if data.size >= 1000

            data = data.reject do |pr|
              GitHub::Data.backports.any? { |b| pr.title&.downcase&.include?(b) }
            end
            all_contributions.concat(data)
            current_date = next_date
          end
          pb.increment
        end
      end
      GitHub::PullRequest.wrap(all_contributions)
    end

    def self.query(org, options = {})
      [
        query_repos(org, options),
        'state:merged',
        'is:pull-request',
        'archived:false',
        'is:closed',
        "merged:#{options[:from]}..#{options[:to]}"
      ].compact.join(' ')
    end

    def self.query_repos(org, options = {})
      if options[:repo] && Array(options[:repo]).any?
        Array(options[:repo]).map do |repo|
          "repo:#{org.name}/#{repo}"
        end.join(' ')
      else
        "org:#{org.name}"
      end
    end
  end
end
