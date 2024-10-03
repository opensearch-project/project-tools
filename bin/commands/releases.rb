# frozen_string_literal: true

module Bin
  class Commands
    desc 'Releases.'
    command 'releases' do |g|
      g.flag %i[o org], desc: 'Name of the GitHub organization.', default_value: 'opensearch-project'
      g.flag %i[repo], multiple: true, desc: 'Search a specific repo within the org.'
      g.flag %i[from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
      g.flag %i[to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1

      g.desc 'Display releases last week.'
      g.command 'latest' do |c|
        c.action do |_global_options, options, _args|
          repos = if options[:repo]&.any?
                    GitHub::Repos.new(options[:repo])
                  else
                    GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project')).repos
                  end
          from = Chronic.parse(options[:from]).to_date if options[:from]
          to = Chronic.parse(options[:to]).to_date if options[:to]
          repos.sort_by(&:name).each do |repo|
            release = repo.latest_release
            next unless release
            next if from && release.created_at < from
            next if to && release.created_at > to

            puts "#{repo.name}: #{release}"
          end
        end
      end
    end
  end
end
