# frozen_string_literal: true

module Bin
  class Commands
    desc 'Data about org members.'
    command 'members' do |g|
      g.desc 'Check GitHub affiliation information for contributors.'
      g.command 'check' do |c|
        c.action do |_global_options, _options, _args|
          GitHub::User.wrap(GitHub::Data.members_data).each do |contributor|
            unless contributor.member?
              puts "#{contributor.login}: #{[contributor.company,
                                             contributor.bio].compact.join(' ')}"
            end
          end
        end
      end
    end
  end
end
