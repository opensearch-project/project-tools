# frozen_string_literal: true

desc 'Data on GitHub pull requests.'
command 'pr', 'prs' do |g|
  g.flag [:page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag [:from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag [:to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag [:repo], multiple: true, desc: 'Search a specific repo within the org.'
  g.switch %i[ignore-unknown], desc: 'Ignore unknown users.', default_value: false

  g.desc 'Lists pull requests in the organization.'
  g.command 'list' do |c|
    c.action do |_global_options, options, _args|
      $org.pull_requests(options).each do |pr|
        puts pr
      end
    end
  end

  g.desc 'Pull request stats.'
  g.command 'stats' do |c|
    c.action do |_global_options, options, _args|
      prs = $org.pull_requests(options)
      if !options['ignore-unknown'] && prs.contributors[:unknown]&.any?
        puts 'Add the following users to either data/users/members.txt, external.txt or contractors.txt and re-run.'
        prs.contributors[:unknown].keys.take(10).each do |user|
          puts user
          system "open https://github.com/#{user}"
        end
      else
        puts "Between #{Chronic.parse(options[:from]).to_date} and #{Chronic.parse(options[:to]).to_date}, #{prs.all_external_percent}% of contributions (#{prs.all_external.size}/#{prs.size}) were made by #{prs.contributors.all_external.size} external contributors (#{prs.contributors.all_external.size}/#{prs.contributors.humans.uniq.size})."
        puts ''
        prs[:external]&.each do |pr|
          puts pr
        end
      end
    end
  end
end
