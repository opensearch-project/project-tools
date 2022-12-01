# frozen_string_literal: true

describe GitHub::Issues do
  context 'labels' do
    context 'org' do
      context 'january 2022', vcr: { cassette_name: 'search/RedHatOfficial/issues_2018-04-18_2018-04-30' } do
        subject do
          GitHub::Issues.new(org: 'RedHatOfficial', from: Date.new(2018, 4, 18), to: Date.new(2018, 4, 30), page: 7)
        end

        it 'fetches labels between two dates' do
          expect(subject.labels.keys.sort).to eq ['content request', 'enhancement', 'pending design feedback', 'v1.2.3', 'v3.4.5']
          expect(subject.labels['enhancement'].count).to eq 1
          expect(subject.labels['v3.4.5'].count).to eq 2
        end

        it 'returns version' do
          expect(subject.version_labels.keys).to eq ['v3.4.5', 'v1.2.3']
        end

        it 'returns repo to versions map' do
          repo = 'https://api.github.com/repos/RedHatOfficial/RedHatOfficial.github.io'
          expect(subject.repos_version_labels.keys).to eq([repo])
          expect(subject.repos_version_labels[repo].keys).to eq(['v3.4.5', 'v1.2.3'])
          expect(subject.repos_version_labels[repo]['v3.4.5'].count).to eq 2
          expect(subject.repos_version_labels[repo]['v3.4.5'].map(&:number)).to eq [171, 174]
          expect(subject.repos_version_labels[repo]['v3.4.5'].first.repository_url).to eq repo
        end

        it 'returns issues older than a date' do
          expect(subject.created_before(Date.new(2018, 1, 1)).count).to eq 0
          expect(subject.created_before(Date.new(2018, 4, 20)).count).to eq 1
          expect(subject.created_before(Date.new(2019, 1, 1)).count).to eq 3
        end
      end
    end

    context 'repo' do
      context 'RedHatOfficial.github.io', vcr: { cassette_name: 'search/RedHatOfficial/RedHatOfficial.github.io/issues_2018-04-18_2018-04-30' } do
        subject do
          GitHub::Issues.new(org: 'RedHatOfficial', repo: 'RedHatOfficial.github.io', from: Date.new(2018, 4, 18), to: Date.new(2018, 4, 30), page: 31)
        end

        it 'fetches issues between two dates' do
          expect(subject.labels.keys.sort).to eq ['content request', 'enhancement', 'pending design feedback', 'v1.2.3', 'v3.4.5']
          expect(subject.labels['enhancement'].count).to eq 1
          expect(subject.labels['v3.4.5'].count).to eq 2
        end
      end
    end
  end

  pending 'repos'
end
