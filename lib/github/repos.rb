# frozen_string_literal: true

module GitHub
  class Repos < Items
    attr_reader :org

    def initialize(obj_or_options = {})
      if obj_or_options.is_a?(Hash)
        @org = obj_or_options[:org]
        super($github.org_repos(org), GitHub::Repo)
      else
        super(obj_or_options, GitHub::Repo)
      end
    end

    def unarchived
      GitHub::Repos.new(reject { |repo| repo.archived })
    end

    def maintainers(dt = nil)
      @maintainers ||= begin
        all = Set.new
        each do |repo|
          maintainers = repo.maintainers(dt)
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

    def externally_maintained
      @externally_maintained ||= begin
        all = Set.new
        Maintainers::ALL_EXTERNAL.each do |bucket|
          each do |repo|
            next unless ((repo.maintainers & maintainers[bucket]) || []).any?

            all.add(repo)
          end
        end
        all
      end
    end

    def all_external_maintained_size
      Maintainers::ALL_EXTERNAL.map do |bucket|
        maintained[bucket]&.size || 0
      end.sum
    end

    def all_external_maintainers_percent
      return 0 unless any?

      (all_external_maintained_size.to_f * 100 / size).to_i
    end
  end
end
