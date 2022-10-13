# frozen_string_literal: true

module GitHub
  class Repos < Array
    attr_reader :org

    def initialize(org)
      @org = org
      super($github.org_repos(org.name))
    end
  end
end
