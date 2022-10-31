# frozen_string_literal: true

module GitHub
  class Repo < Item
    def initialize(id_or_obj)
      if id_or_obj.is_a?(Sawyer::Resource)
        super id_or_obj
      else
        super $github.repo(id_or_obj)
      end
    rescue Octokit::NotFound => e
      raise "Invalid repo: #{id_or_obj}: #{e.message}"
    end

    def maintainers
      @maintainers ||= begin
        data = $github.contents(full_name, path: 'MAINTAINERS.md')
        md = Base64.decode64(data.content)
        data = {}
        parsed = Redcarpet::Markdown.new(MaintainersExtractor, tables: true, target: data).render(md)
        data[:maintainers]
      rescue Octokit::NotFound
        nil
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
  end
end
