# frozen_string_literal: true

module GitHub
  class Items < Array
    include GitHub::Progress
    include GitHub::RateLimited

    def initialize(arr_or_options, klass)
      if arr_or_options.is_a?(Array)
        super(klass.wrap(arr_or_options))
      elsif arr_or_options.is_a?(Hash)
        super(fetch(arr_or_options, klass))
      else
        raise ArgumentError, "Unexpected #{arr_or_options.class}"
      end
    end

    def page(_options)
      raise 'Implement #page to get a page of data.'
    end

    def fetch(options, klass)
      items = []
      start_at = options[:from].is_a?(String) ? Chronic.parse(options[:from]).to_date : options[:from]
      end_at = options[:to].is_a?(String) ? Chronic.parse(options[:to]).to_date : options[:to]
      days = options[:page]
      raise ArgumentError, 'missing from' unless start_at
      raise ArgumentError, 'missing to' unless end_at
      raise ArgumentError, 'missing page' unless days

      progress(
        total: (((end_at - start_at) / days) + 1),
        title: "Fetching between #{start_at} and #{end_at}"
      ) do |pb|
        current_date = start_at
        while current_date < end_at
          rate_limited do
            next_date = [current_date + days, end_at].min
            items.concat(page(options.merge(from: current_date, to: next_date)))
            current_date = next_date
          end
          pb.increment
        end
      end
      klass.wrap(items)
    end
  end
end
