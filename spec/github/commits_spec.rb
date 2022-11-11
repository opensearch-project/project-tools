# frozen_string_literal: true

describe GitHub::Commits do
  context 'with contributors' do
    context 'with org' do
      context 'with january 2022' do
        context 'with OpenSearch commits', vcr: { cassette_name: 'search/opensearch-project/commits_2022-01-01_2022-01-31' } do
          subject(:commits) do
            described_class.new(org: 'opensearch-project', repo: 'OpenSearch', from: Date.new(2022, 1, 1), to: Date.new(2022, 1, 31), page: 7)
          end

          it 'fetches commits between two dates' do
            expect(commits.count).to eq 62
            expect(commits.first['sha']).to eq 'db23f72a2a5da1f21d674bde3a9d1cbe4fb74b19'
          end

          it 'collects DCO signers from commits' do
            expect(commits.dco_signers.count).to eq 25
            expect(commits.dco_signers.first.name).to eq 'Tianli Feng'
          end
        end
      end
    end
  end
end
