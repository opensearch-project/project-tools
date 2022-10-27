# frozen_string_literal: true

desc 'Repos.'
command 'repos' do |g|
  g.flag %i[o org], desc: 'Name of the GitHub organization.', default_value: 'opensearch-project'

  g.desc 'List repos in the GitHub organization.'
  g.command 'list' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      org.repos.sort_by(&:name).each do |repo|
        puts repo.name
      end
    end
  end
end
