# frozen_string_literal: true

module GitHub
  module Data
    class << self
      DATA = File.expand_path('../../data', __dir__)
      USERS_DATA = File.expand_path('users', DATA)
      MEMBERS = File.expand_path('members.txt', USERS_DATA)
      CONTRACTORS = File.expand_path('contractors.txt', USERS_DATA)
      EXTERNAL = File.expand_path('external.txt', USERS_DATA)
      STUDENTS = File.expand_path('students.txt', USERS_DATA)
      BOTS = File.expand_path('bots.txt', USERS_DATA)
      COMPANIES = File.expand_path('companies.txt', USERS_DATA)
      BACKPORTS = File.expand_path('prs/backports.txt', DATA)

      def load_list(path)
        if File.exist?(path)
          File.readlines(path).map(&:strip).reject(&:blank?)
        else
          warn "Missing #{path}, ignored. Ask @dblock where to get this data from."
          []
        end
      end

      def data
        DATA
      end

      def backports_data
        @backports_data ||= load_list(BACKPORTS)
      end

      def members_data
        @members_data ||= load_list(MEMBERS)
      end

      def contractors_data
        @contractors_data ||= load_list(CONTRACTORS)
      end

      def external_data
        @external_data ||= load_list(EXTERNAL)
      end

      def students_data
        @students_data ||= load_list(STUDENTS)
      end

      def bots_data
        @bots_data ||= load_list(BOTS)
      end

      def companies_data
        @companies_data ||= load_list(COMPANIES)
      end

      def all_members_data
        members_data
      end

      def check_dups!
        %i[members_data contractors_data students_data external_data].combination(2).each do |l, r|
          send(l).intersection(send(r)).each do |user|
            warn "WARNING: #{user} is found in both #{l} and #{r}"
          end
        end
      end

      def all_external_data
        all = []
        Maintainers::ALL_EXTERNAL.each do |bucket|
          all.concat(send("#{bucket}_data"))
        end
        all
      end
    end
  end
end
