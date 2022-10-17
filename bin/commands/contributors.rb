# frozen_string_literal: true

desc 'Data about contributors.'
command 'contributors' do |g|
  g.flag [:page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag [:from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag [:to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag [:repo], multiple: true, desc: 'Search a specific repo within the org.'

  g.desc 'Operate on a set of contributors.'
  g.command 'list' do |c|
    c.action do |_global_options, options, _args|
      $org.pull_requests(options).contributors.humans.sort.uniq.each do |pr|
        puts pr
      end
    end
  end

  g.desc 'Contributor stats.'
  g.command 'stats' do |c|
    c.action do |_global_options, options, _args|
      buckets = $org.pull_requests(options).contributors.buckets
      puts "total = #{buckets.values.map(&:size).sum}"
      buckets.each_pair do |bucket, logins|
        puts "#{bucket} (#{logins.size}):"
        logins.sort_by { |_k, v| -v }.each do |login, count|
          puts " https://github.com/#{login}: #{count}"
        end
      end
    end
  end
end
