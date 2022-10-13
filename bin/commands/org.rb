# frozen_string_literal: true

desc 'Data about a GitHub organization.'
command 'org' do |g|
  g.desc 'Provides basic information about the GitHub organization.'
  g.command 'info' do |c|
    c.action do |_global_options, _options, _args|
      puts $org.info
    end
  end

  g.command 'members' do |c|
    c.action do |_global_options, _options, _args|
      puts "org: #{$org.name}"
      puts "members: #{$org.members.count}"
      puts "missing in data/users/members.txt: #{($org.members.logins - GitHub::Data.members).join(' ')}"
      puts "no longer members: #{(GitHub::Data.members - $org.members.logins).join(' ')}"
    end
  end
end
