# frozen_string_literal: true

module GitHub
  class Team < Item
    include Comparable

    def initialize(id_or_obj)
      super(id_or_obj, :team)
    end

    def repos
      @repos ||= GitHub::Repo.wrap($github.team_repos(id))
    end
  end
end
