# frozen_string_literal: true

module GitHub
  class Repos < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      @org = obj_or_options[:org]
      super $github.org_repos(org), GitHub::Repo
    end
  end
end
