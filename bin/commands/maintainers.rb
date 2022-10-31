# frozen_string_literal: true

desc 'Data about repo maintainers.'
command 'maintainers' do |g|
  g.desc 'Show MAINTAINERS.md stats.'
  g.command 'stats' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
      repos = org.repos.sort_by(&:name)
      puts "# Missing Maintainers\n"
      repos.select { |repo| repo.maintainers.nil? }.each do |repo|
        puts repo.html_url
      end
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
end
