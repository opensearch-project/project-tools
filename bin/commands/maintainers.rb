# frozen_string_literal: true

module Bin
  class Commands
    desc 'Data about repo maintainers.'
    command 'maintainers' do |g|
      g.desc 'Show MAINTAINERS.md stats.'
      g.command 'stats' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          all = Set.new
          repos.each do |repo|
            maintainers = repo.maintainers
            maintainers&.each do |user|
              all.add(user)
            end
          end
          buckets = GitHub::Maintainers.new(all.to_a).buckets
          puts "\n# Maintainers\n"
          puts "unique: #{buckets.values.map(&:size).sum}"
          buckets.each_pair do |bucket, logins|
            puts "#{bucket}: #{logins.size} (#{logins.map(&:to_s).join(', ')})"
          end
          puts "\n# External Maintainers\n"
          repos.each do |repo|
            next unless repo.maintainers

            external_maintainers = repo.maintainers & buckets[:external]
            next unless external_maintainers&.any?

            puts "#{repo.html_url}: #{external_maintainers}"
          end
          puts "\n# Unknown Maintainers\n"
          repos.each do |repo|
            next unless repo.maintainers

            unknown_maintainers = repo.maintainers & buckets[:unknown]
            next unless unknown_maintainers&.any?

            puts "#{repo.html_url}: #{unknown_maintainers}"
          end
        end
      end

      g.command 'missing' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          repos.select { |repo| repo.maintainers.nil? }.each do |repo|
            puts repo.html_url
          end
        end
      end

      g.desc 'Audit MAINTAINERS.md and CODEOWNERS.'
      g.command 'audit' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          repos.each do |repo|
            problems = {}
            repo.maintainers&.each do |user|
              next if repo.codeowners&.include?(user)

              problems[:missing_in_codeowners] ||= []
              problems[:missing_in_codeowners] << user
            end
            repo.codeowners&.each do |user|
              next if repo.maintainers&.include?(user)

              problems[:missing_in_maintainers] ||= []
              problems[:missing_in_maintainers] << user
            end
            next unless problems.any?

            puts "#{repo.html_url}: #{repo.maintainers&.count}"
            problems.each_pair do |k, v|
              puts " #{k}: #{v}" if v.any?
            end
          end
        end
      end

      g.desc 'Audit MAINTAINERS.md that have never contributed.'
      g.command 'contributors' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          repos.each do |repo|
            users = repo.maintainers&.map do |user|
              commits = $github.commits(repo.full_name, author: user)
              next if commits.any?

              user
            end&.compact
            puts "#{repo.html_url}: #{users}" if users&.any?
          end
        end
      end

      g.desc 'Compare MAINTAINERS.md and CODEOWNERS with repo permissions.'
      g.command 'permissions' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          repos.each do |repo|
            if repo.oss_problems.any?
              puts "#{repo.html_url}"
              repo.oss_problems.each_pair do |problem, desc|
                puts "  #{problem}: #{desc}"
              end
            else
              puts "#{repo.html_url}: OK"
            end
          end
        end
      end
    end
  end
end
