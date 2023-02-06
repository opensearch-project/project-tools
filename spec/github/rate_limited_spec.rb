# frozen_string_literal: true

describe GitHub::RateLimited do
  include GitHub::RateLimited

  let(:rate_limit) { Octokit::RateLimit.new }

  before do
    allow(self).to receive(:sleep)
    allow(rate_limit).to receive(:resets_in).and_return 0
    allow($github).to receive(:rate_limit).and_return rate_limit
  end

  it 'retries on a rate limit' do
    iteration = 0
    raised = false
    calls = []
    rate_limited do
      until iteration == 2
        calls << iteration
        unless raised
          raised = true
          raise Octokit::TooManyRequests
        end
        iteration += 1
      end
    end
    expect(calls).to eq [0, 0, 1]
  end
end
