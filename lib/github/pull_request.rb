# frozen_string_literal: true

module GitHub
  class PullRequest < Item
    def short_url
      html_url.split('/')[4..].join('/').gsub('/pull/', '#')
    end

    def repo_url
      repository_url.split('/')[4, 2].join('/')
    end

    def dco_signers
      commits.dco_signers
    end

    def commits(options = {})
      @commits ||= GitHub::Commits.new($github.pull_request_commits(repo_url, number, options))
    end

    def to_s
      "#{html_url}: #{title} - [@#{user.login}]"
    end
  end
end
