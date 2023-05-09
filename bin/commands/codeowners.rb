# frozen_string_literal: true

module Bin
  class Commands
    desc 'Data about CODEOWNERS.'
    command 'codeowners' do |g|
      g.command 'audit' do |c|
        c.desc 'Find repos that are missing a CODEOWNERS file or have multiple.'
        c.action do |_global_options, options, _args|
          org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
          repos = org.repos.sort_by(&:name)
          repos.each do |repo|
            if repo.codeowners_files.size > 1
              puts "#{repo.html_url}: #{repo.codeowners_files}"
            elsif repo.codeowners.nil?
              puts "#{repo.html_url}: missing"
            end
          end
        end
      end
    end
  end
end
