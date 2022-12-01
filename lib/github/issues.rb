# frozen_string_literal: true

module GitHub
  class Issues < Items
    def initialize(id_or_options)
      super id_or_options, GitHub::Issue
    end

    def version_labels
      @version_labels ||= labels.select do |label, _issues|
        label.match(/v[0-9]\.[0-9]\.[0-9]*/)
      end
    end

    # map of repo -> labels
    def repos_version_labels
      @repos_version_labels ||= begin
        all = {}
        version_labels.each do |label, issues|
          issues.each do |issue|
            all[issue.repository_url] ||= {}
            all[issue.repository_url][label] ||= []
            all[issue.repository_url][label] << issue
          end
        end
        all
      end
    end

    def created_before(created_at)
      select { |issue| issue.created_at < created_at }
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

    def page(options = {})
      data = $github.search_issues(query(options), per_page: 1000).items
      raise "There are 1000+ issues returned from a single query for #{days} day(s), reduce --page." if data.size >= 1000

      data
    end

    def query(options = {})
      GitHub::Searchables.new(options).to_a.concat(
        [
          'is:issue',
          'is:open',
          'archived:false',
          "created:#{options[:from]}..#{options[:to]}",
          options.key?(:label) ? "label:\"#{options[:label]}\"" : nil
        ]
      ).compact.join(' ')
    end
  end
end
