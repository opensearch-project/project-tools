# frozen_string_literal: true

module GitHub
  class Repos < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      if obj_or_options.is_a?(Hash)
        @org = obj_or_options[:org]
        super $github.org_repos(org), GitHub::Repo
      else
        super obj_or_options, GitHub::Repo
      end
    end

    def unarchived
      GitHub::Repos.new(reject { |repo| repo.archived })
    end

    def maintainers
      @maintainers ||= begin
        all = Set.new
        each do |repo|
          maintainers = repo.maintainers
          maintainers&.each do |user|
            all.add(user)
          end
        end
        GitHub::Maintainers.new(all.to_a)
      end
    end

    def maintained
      @maintained ||= begin
        all = {}
        maintainers.buckets.keys.each do |bucket|
          each do |repo|
            all[bucket] ||= []
            all[bucket] << repo if ((repo.maintainers & maintainers[bucket]) || []).any?
          end
        end
        all
      end
    end

    def external_maintainers_percent
      return 0 unless any?

      (((maintained[:external].size.to_f + maintained[:students].size.to_f) / size) * 100).to_i
    end
  end
end
