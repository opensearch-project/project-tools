# frozen_string_literal: true

desc 'Repos.'
command 'repos' do |g|
  g.desc 'Lists repos in the organization.'
  g.command 'list' do |c|
    c.action do |_global_options, _options, _args|
      $org.repos.sort_by(&:name).each do |repo|
        puts repo.name
      end
    end
  end
end
