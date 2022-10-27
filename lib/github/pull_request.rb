# frozen_string_literal: true

module GitHub
  class PullRequest < Item
    def short_url
      html_url.split('/')[4..].join('/').gsub('/pull/', '#')
    end

    def to_s
      "#{html_url}: #{title} - [@#{user.login}]"
    end
  end
end
