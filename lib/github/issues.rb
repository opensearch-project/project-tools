# frozen_string_literal: true

module GitHub
  class Issues < Array
    extend GitHub::RateLimited
    extend GitHub::Progress

    attr_reader :org

    def initialize(org, options = {})
      @org = org
      super(Issues.fetch(org, options))
    end

    def version_labels
      labels.select do |label, _issues|
        label.match(/v[0-9]\.[0-9]\.[0-9]*/)
      end
    end

    def labels
      @labels ||= begin
        all = {}
        each do |issue|
          issue.labels.each do |label|
            all[label.name] ||= []
            all[label.name] << issue
          end
        end
        all.sort_by { |_, v| -v.length }.to_h
      end
    end

    def repos
      @repos ||= begin
        all = {}
        each do |issue|
          all[issue.repository_url] ||= []
          all[issue.repository_url] << issue
        end
        all.sort_by { |_, v| -v.length }.to_h
      end
    end

    def self.fetch(org, options = {})
      issues = []
      start_at = options[:from].is_a?(String) ? Chronic.parse(options[:from]).to_date : options[:from]
      end_at = options[:to].is_a?(String) ? Chronic.parse(options[:to]).to_date : options[:to]
      days = options[:page]
      progress(
        total: (((end_at - start_at) / days) + 1),
        title: "Fetching issues between #{start_at} and #{end_at}"
      ) do |pb|
        current_date = start_at
        while current_date < end_at
          rate_limited do
            next_date = [current_date + days, end_at].min
            response = $github.search_issues(query(org, options.merge(from: current_date, to: next_date)), per_page: 1000)
            data = response.items
            raise "There are 1000+ issues returned from a single query for #{days} day(s), reduce --page." if data.size >= 1000

            issues.concat(data)
            current_date = next_date
          end
          pb.increment
        end
      end
      GitHub::Issue.wrap(issues)
    end

    def self.query(org, options = {})
      [
        "org:#{org.name}",
        'is:issue',
        'is:open',
        'archived:false',
        "created:#{options[:from]}..#{options[:to]}",
        options.key?(:label) ? "label:\"#{options[:label]}\"" : nil
      ].compact.join(' ')
    end
  end
end
