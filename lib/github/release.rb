# frozen_string_literal: true

module GitHub
  class Release < Item
    def to_s
      [
        "#{name}, created #{DOTIW::Methods.distance_of_time_in_words(created_at, Time.now, highest_measures: 1)} ago",
        "  #{html_url}"
      ].join("\n")
    end
  end
end
