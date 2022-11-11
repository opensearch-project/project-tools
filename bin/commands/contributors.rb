# frozen_string_literal: true

desc 'Data about contributors.'
command 'contributors' do |g|
  g.flag %i[page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag %i[from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag %i[to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag %i[o org], desc: 'Name of the GitHub organization.', default_value: 'opensearch-project'
  g.flag %i[repo], multiple: true, desc: 'Search a specific repo within the org.'

  g.desc 'List contributors.'
  g.command 'list' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      org.pull_requests(options).contributors.humans.sort.uniq.each do |pr|
        puts pr
      end
    end
  end

  g.desc 'Show contributor stats.'
  g.command 'stats' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      buckets = org.pull_requests(options).contributors.buckets
      puts "total = #{buckets.values.map(&:size).sum}"
      buckets.each_pair do |bucket, logins|
        puts "#{bucket} (#{logins.size}):"
        logins.sort_by { |_k, v| -v }.each do |login, count|
          puts " https://github.com/#{login}: #{count}"
        end
      end
    end
  end

  g.desc 'Create a list of all DCO signers'
  g.command 'dco-signers' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      signers = org.commits(options).dco_signers
      signers.sort_for_display.each do |signer|
        puts signer.to_s
      end
    end
  end
end
