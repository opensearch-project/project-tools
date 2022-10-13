# frozen_string_literal: true

module GitHub
  class Users < Array
    attr_reader :org

    def initialize(org)
      @org = org
      super($github.org_members(org.name))
    end

    def logins
      map(&:login)
    end
  end
end
