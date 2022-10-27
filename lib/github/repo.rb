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
  end
end
