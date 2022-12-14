# frozen_string_literal: true

module GitHub
  class Users < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      @org = obj_or_options[:org]
      super $github.org_members(org), GitHub::Users
    end

    def logins
      map(&:login)
    end
  end
end
