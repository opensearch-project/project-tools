# frozen_string_literal: true

module GitHub
  class Repo < Item
    def initialize(id_or_obj)
      if id_or_obj.is_a?(Sawyer::Resource)
        super(id_or_obj)
      else
        super($github.repo(id_or_obj))
      end
    rescue Octokit::NotFound => e
      raise "Invalid repo: #{id_or_obj}: #{e.message}"
    end

    def maintainers_md(dt = nil)
      @maintainers_md ||= begin
        if dt
          $github.commits(full_name, path: 'MAINTAINERS.md').each do |commit|
            next unless commit.commit.author[:date] < dt

            # puts "Fetched #{full_name}, path=MAINTAINERS.md, ref=#{commit.sha}"
            data = $github.contents(full_name, path: 'MAINTAINERS.md', query: { ref: commit.sha })
            return Base64.decode64(data.content)
          end
          nil
        else
          data = $github.contents(full_name, path: 'MAINTAINERS.md')
          Base64.decode64(data.content)
        end
      rescue Octokit::NotFound
        nil
      end
    end

    def maintainers(dt = nil)
      @maintainers ||= begin
        data = {}
        content = maintainers_md(dt)
        parsed = Redcarpet::Markdown.new(MaintainersExtractor, tables: true, target: data).render(content) if content
        GitHub::Maintainers.new(data[:maintainers]) if data && data.key?(:maintainers)
      rescue Octokit::NotFound
        nil
      end
    end

    def codeowners_files
      @codeowners_files ||= ['.github/CODEOWNERS', 'CODEOWNERS'].map do |filename|
        $github.contents(full_name, path: filename)
        filename
      rescue Octokit::NotFound
        nil
      end.compact
    end

    def codeowners
      @codeowners ||= begin
        data = $github.contents(full_name, path: '.github/CODEOWNERS')
        content = Base64.decode64(data.content)
        lines = content.split("\n").reject { |part| part[0] == '#' }
        lines.reject(&:blank?).map do |line|
          users = line.split(' ')[1..]
          users&.map { |user| user[1..] }
        end.flatten
      rescue Octokit::NotFound
        nil
      end
    end

    def collaborators
      @collaborators ||= GitHub::User.wrap($github.collaborators(full_name))
    end

    def maintainers_not_collaborators
      maintainers&.select do |user|
        !collaborators.map(&:login).include?(user)
      end
    end

    def oss_problems
      oss_problems ||= begin
        problems = {}

        if maintainers.nil?
          problems['MAINTAINERS.md'] = 'missing'
        elsif !maintainers_md&.include?('https://github.com/opensearch-project/.github/blob/main/RESPONSIBILITIES.md')
          problems['MAINTAINERS.md'] = 'missing link to RESPONSIBILITIES.md'
        end

        problems['CODEOWNERS'] = 'missing' if codeowners.nil?

        begin
          problems['COLLABORATORS'] = "out of sync (#{maintainers_not_collaborators})" if maintainers_not_collaborators&.any?
        rescue Octokit::Forbidden
          problems['COLLABORATORS'] = 'access denied'
        end

        problems
      end
    end

    class MaintainersExtractor < Redcarpet::Render::Base
      attr_reader :section, :rows, :cols

      def header(text, _header_level)
        if ['Maintainers', 'Current Maintainers'].include?(text)
          @section = true
          @cols = 0
          @rows = 0
        else
          @section = false
          @rows = 0
        end
        nil
      end

      def table_row(_content)
        @cols = 0
        @rows += 1 if section
        nil
      end

      def link(_link, _title, content)
        content
      end

      def table_cell(content, _alignment)
        @cols += 1 if @section
        if rows >= 1 && cols == 2
          @options[:target][:maintainers] ||= []
          @options[:target][:maintainers] << content
        end
        nil
      end
    end

    def releases
      @releases ||= GitHub::Release.wrap($github.releases(full_name))
    end

    def latest_release
      @latest_release ||= GitHub::Release.new($github.latest_release(full_name))
    rescue Octokit::NotFound
      nil
    end
  end
end
