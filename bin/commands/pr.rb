# frozen_string_literal: true

desc 'Data on GitHub pull requests.'
command 'pr', 'prs' do |g|
  g.flag %i[page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag %i[from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag %i[to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag %i[o org], desc: 'Name of the GitHub organization.'
  g.flag %i[repo], multiple: true, desc: 'Search a specific repo within the org.'
  g.switch %i[ignore-unknown], desc: 'Ignore unknown users.', default_value: false
  g.flag %i[status], desc: 'Query for opened or merged pull requests.', default_value: :merged, must_match: %i[merged unmerged]

  g.desc 'List pull requests in the organization.'
  g.command 'list' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
      org.pull_requests(options).each do |pr|
        puts pr
      end
    end
  end

  g.desc 'Show pull request stats.'
  g.command 'stats' do |c|
    c.action do |_global_options, options, _args|
      prs = GitHub::PullRequests.new(options)

      if !options['ignore-unknown'] && prs.contributors[:unknown]&.any?
        puts 'Add the following users to either data/users/members.txt, external.txt or contractors.txt and re-run.'
        prs.contributors[:unknown].keys.take(10).each do |user|
          puts user
          system "open https://github.com/#{user}"
        end
      else
        puts "Between #{Chronic.parse(options[:from]).to_date} and #{Chronic.parse(options[:to]).to_date}, #{prs.all_external_percent}% of contributions (#{prs.all_external.size}/#{prs.size}) were made by #{prs.contributors.all_external.size} external contributors (#{prs.contributors.all_external.size}/#{prs.contributors.humans.uniq.size})."
        puts ''
        prs.percent.each_pair do |k, v|
          puts "#{k}: #{v}% (#{prs.buckets[k].size})"
        end
        if prs[:external]&.size&.< 25
          puts ''
          prs[:external]&.each do |pr|
            puts pr
          end
        end
      end
    end
  end
end
