# frozen_string_literal: true

desc 'Data on GitHub issues.'
command 'issue', 'issues' do |g|
  g.flag [:page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag [:from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag [:to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag [:repo], multiple: true, desc: 'Search a specific repo within the org.'

  g.desc 'Lists issue stats in the organization.'
  g.command 'labels' do |c|
    c.action do |_global_options, options, _args|
      $org.issues(options).labels.take(25).each do |label, issues|
        puts "#{label}: #{issues.count}"
      end
    end
  end

  g.desc 'Finds oldest untriaged offenders.'
  g.command 'untriaged' do |c|
    c.action do |_global_options, options, _args|
      untriaged_issues = $org.issues(options.merge(label: 'untriaged'))
      puts "There are #{untriaged_issues.count} untriaged issues created between #{Chronic.parse(options[:from]).to_date} and #{Chronic.parse(options[:to]).to_date}."
      puts "\n# By Repo\n"
      untriaged_issues.repos.each_pair do |repo, issues|
        puts "#{repo}: #{issues.count}"
      end
      puts "\n# Oldest Issues\n"
      untriaged_issues.sort_by { |i| i.created_at }.take(25).each do |issue|
        puts "#{issue}, created #{DOTIW::Methods.distance_of_time_in_words(issue.created_at, Time.now,
                                                                           highest_measures: 1)} ago"
      end
    end
  end

  g.desc 'Finds labelled for incorrect release.'
  g.command 'released' do |c|
    c.action do |_global_options, options, _args|
      issues = $org.issues(options)
      puts "# Label Counts\n"
      issues.version_labels.sort.each do |label, issues|
        puts "#{label}: #{issues.count}"
      end
      puts "\n# By Repo\n"
      issues.repos_version_labels.sort.each do |repo, version_labels|
        puts "#{repo.split('/').last}"
        version_labels.sort.each do |label, issues|
          puts "  #{label}: #{issues.count}"
        end
      end
    end
  end
end
