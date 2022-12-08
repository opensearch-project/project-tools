# frozen_string_literal: true

module GitHub
  class Item < SimpleDelegator
    extend GitHub::RateLimited

    def initialize(id_or_obj, m = nil)
      if id_or_obj.is_a?(Sawyer::Resource)
        super id_or_obj
      elsif m
        super $github.send(m, id_or_obj)
      else
        raise "Missing Octokit method for #{id_or_obj}"
      end
    rescue Octokit::NotFound => e
      raise "Invalid #{self.class.name.downcase}: #{id_or_obj}: #{e.message}"
    end

    def self.wrap(collection)
      result = []
      rate_limited do
        collection&.each do |obj|
          result.push(obj.is_a?(Item) ? obj : new(obj))
        end
      end
      result
    end
  end
end
