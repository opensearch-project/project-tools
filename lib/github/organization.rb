# frozen_string_literal: true

module GitHub
  class Organization
    attr_reader :name

    def initialize(options)
      @name = options[:org]
    end

    def org
      @org ||= $github.org(name)
    end

    def repos
      @repos ||= GitHub::Repos.new({ org: name }).reject { |repo| repo.archived }
    end

    def members
      @members ||= GitHub::Users.new({ org: name })
    end

    def teams
      @teams ||= GitHub::Teams.new({ org: name })
    end

    def pull_requests(options = {})
      @pull_requests ||= GitHub::PullRequests.new({ org: name, status: :merged }.merge(options))
    end

    def commits(options = {})
      @commits ||= GitHub::Commits.new({ org: name }.merge(options))
    end

    def issues(options = {})
      @issues ||= GitHub::Issues.new({ org: name }.merge(options))
    end

    def info
      [
        "name: #{org.name}",
        "description: #{org.description}",
        "url: #{org.url}",
        "repos: #{repos.count}"
      ].join("\n")
    end
  end
end
