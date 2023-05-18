# frozen_string_literal: true

module Bin
  class Commands
    desc 'Data about repo maintainers.'
    command 'maintainers' do |g|
      g.desc 'Show MAINTAINERS.md stats.'
      g.command 'stats' do |c|
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          maintainers = org.repos.maintainers
          puts "As of #{Date.today}, #{org.repos.count} repos have #{maintainers.unique_count} maintainers, including #{org.repos.external_maintainers_percent}% (#{org.repos.maintained[:external].size + org.repos.maintained[:students].size}/#{org.repos.count}) of repos with at least one of #{maintainers.external_unique_count} external maintainers."
          puts "\n# Maintainers\n"
          puts "unique: #{maintainers.unique_count}"
          maintainers.each_pair do |bucket, logins|
            puts "#{bucket}: #{logins.size} (#{logins.map(&:to_s).join(', ')})"
          end
          puts "\n# External Maintainers\n"
          org.repos.maintained[:external].sort_by(&:name).each do |repo|
            puts "#{repo.html_url}: #{repo.maintainers[:external]}"
          end

          puts "\n# Student Maintainers\n"
          org.repos.maintained[:students].sort_by(&:name).each do |repo|
            puts "#{repo.html_url}: #{repo.maintainers[:students]}"
          end

          puts "\n# Unknown Maintainers\n"
          org.repos.maintained[:unknown].sort_by(&:name).each do |repo|
            puts "#{repo.html_url}: #{repo.maintainers[:unknown]}"
          end
        end
      end

      g.desc 'Audit repos for missing MAINTAINERS.md.'
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
          total_users = 0
          total_repos = 0
          unique_users = Set.new
          repos.each do |repo|
            users = repo.maintainers&.map do |user|
              commits = $github.commits(repo.full_name, author: user)
              next if commits.any?

              user
            end&.compact
            next unless users&.any?

            total_users += users.count
            total_repos += 1
            unique_users.add(users)
            puts "#{repo.html_url}: #{users}" if users&.any?
          end
          puts "\nThere are #{unique_users.count} unique names in #{total_users} instances of users listed in MAINTAINERS.md that have never contributed across #{total_repos}/#{repos.count} repos."
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
