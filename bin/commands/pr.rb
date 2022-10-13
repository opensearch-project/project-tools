# frozen_string_literal: true

desc 'Data on GitHub pull requests.'
command 'pr', 'prs' do |g|
  g.flag [:page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag [:from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag [:to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1

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
      if prs.contributors[:unknown]&.any?
        puts 'Add the following users to either data/users/members.txt, external.txt or contractors.txt and re-run.'
        prs.contributors[:unknown].keys.take(10).each do |user|
          puts user
          system "open https://github.com/#{user}"
        end
      else
        puts "Between #{options[:from]} and #{options[:to]}, #{prs.all_external_percent}% of contributions (#{prs.all_external.size}/#{prs.size}) were made by #{prs.contributors.all_external.size} external contributors (#{prs.contributors.all_external.size}/#{prs.contributors.humans.uniq.size})."
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
