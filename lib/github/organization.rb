# frozen_string_literal: true

module GitHub
  class Organization
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def org
      @org ||= $github.org(name)
    end

    def repos
      @repos ||= GitHub::Repos.new(self)
    end

    def members
      @members ||= GitHub::Users.new(self)
    end

    def pull_requests(options = {})
      @pull_requests ||= GitHub::PullRequests.new({ org: name }.merge(options))
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
