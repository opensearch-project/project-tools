# frozen_string_literal: true

module GitHub
  class Teams < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      if obj_or_options.is_a?(Hash)
        @org = obj_or_options[:org]
        super $github.organization_teams(org), GitHub::Team
      else
        super obj_or_options, GitHub::Team
      end
    end
  end
end
