# frozen_string_literal: true

module GitHub
  class Users < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      if obj_or_options.is_a?(Hash)
        @org = obj_or_options[:org]
        super($github.org_members(org), GitHub::Users)
      else
        super(obj_or_options, GitHub::Users)
      end
    end

    def logins
      map(&:login)
    end
  end
end
