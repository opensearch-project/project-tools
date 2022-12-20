# frozen_string_literal: true

module GitHub
  class Commits < Items
    def initialize(arr_or_options)
      super arr_or_options, GitHub::Commit
    end

    # Gets all unique DCO signers (by email address) from all commits
    def dco_signers
      Signers.new(each.map(&:dco_signers).flatten)
    end

    def page(options)
      data = $github.search_commits(query(options), per_page: 1000).items
      raise 'There are 1000+ commits returned from a single query, reduce --page.' if data.size >= 1000

      data.reject do |commit|
        commit.commit.author.email.include?('[bot]')
      end
    end

    def query(options = {})
      GitHub::Searchables.new(options).to_a.concat(
        [
          "committer-date:#{options[:from]}..#{options[:to]}"
        ]
      ).compact.join(' ')
    end
  end
end
