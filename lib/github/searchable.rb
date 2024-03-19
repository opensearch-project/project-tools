# frozen_string_literal: true

module GitHub
  class Searchable
    attr_reader :name, :qualifier

    def initialize(qualifier, name)
      @name = name
      @qualifier = qualifier
    end

    def to_s
      [
        qualifier,
        name
      ].join(':')
    end
  end

  class SearchableRepo < Searchable
    def initialize(name, org = nil)
      super('repo', [org, name].compact.join('/'))
    end
  end

  class SearchableOrg < Searchable
    def initialize(name)
      super('org', name)
    end
  end

  class Searchables < Array
    def initialize(options = {})
      super([])
      orgs = Array(options[:org])
      repos = Array(options[:repo])
      repo_in_org = false
      repos.each do |repo|
        if repo.split('/').count == 1
          raise ArgumentError, "Org name required for '#{repo}'." if orgs.count == 0
          raise ArgumentError, "Org name required for '#{repo}' when multiple orgs are specified." if orgs.count != 1

          repo_in_org = true
          push GitHub::SearchableRepo.new(repo, orgs.first)
        else
          push GitHub::SearchableRepo.new(repo)
        end
      end
      concat(orgs.map { |org| GitHub::SearchableOrg.new(org) }) unless repo_in_org
      push GitHub::SearchableOrg.new('opensearch-project') if none?
    end

    def to_s
      map(&:to_s).join(' ')
    end

    def to_a
      map(&:to_s)
    end
  end
end
