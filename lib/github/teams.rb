# frozen_string_literal: true

module GitHub
  class Teams < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      @org = obj_or_options[:org]
      super $github.organization_teams(org), GitHub::Team
    end
  end
end
