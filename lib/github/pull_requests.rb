# frozen_string_literal: true

module GitHub
  class PullRequests < Items
    include GitHub::Buckets

    def initialize(arr_or_options)
      super(arr_or_options, GitHub::PullRequest)
    end

    def contributors
      @contributors ||= GitHub::Contributors.new(map(&:user))
    end

    def buckets
      @buckets ||= begin
        buckets = {}
        each do |pr|
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
        pr.user.type == 'Bot' || GitHub::Data.backports.any? { |b| pr.title&.downcase&.include?(b) } || project_website_authors?(pr)
      end
    end

    def query(options = {})
      GitHub::Searchables.new(options).to_a.concat(
        [
          options[:status] == :merged ? 'state:merged' : nil,
          'is:pull-request',
          'archived:false',
          options[:status] == :merged ? 'is:closed' : 'is:unmerged',
          options[:status] == :merged ? "merged:#{options[:from]}..#{options[:to]}" : "created:#{options[:from]}..#{options[:to]}"
        ].compact
      ).compact.join(' ')
    end

    # exclude a high number of misleading contributions from a student program
    # modifying https://github.com/opensearch-project/project-website/commits/main/_authors
    def project_website_authors?(pr)
      return false unless pr.repository_url == 'https://api.github.com/repos/opensearch-project/project-website'

      repo = pr.repository_url.split('/')[4, 2].join('/')
      files = $github.pull_request_files(repo, pr.number)
      files.all? { |file| file.filename.start_with?('_authors/') }
    end
  end
end
