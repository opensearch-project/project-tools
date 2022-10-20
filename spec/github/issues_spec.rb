# frozen_string_literal: true

describe GitHub::Issues do
  let(:org) { GitHub::Organization.new('RedHatOfficial') }

  context 'labels' do
    context 'org' do
      context 'january 2022', vcr: { cassette_name: 'search/RedHatOfficial/issues_2018-04-18_2018-04-30' } do
        subject do
          GitHub::Issues.new(org, from: Date.new(2018, 4, 18), to: Date.new(2018, 4, 30), page: 7)
        end

        it 'fetches labels between two dates' do
          expect(subject.labels.keys.sort).to eq ['content request', 'enhancement', 'help wanted', 'on hold', 'pending design feedback']
          expect(subject.labels['enhancement'].count).to eq 1
          expect(subject.labels['on hold'].count).to eq 2
        end
      end
    end

    context 'repo' do
      context 'RedHatOfficial.github.io', vcr: { cassette_name: 'search/RedHatOfficial/RedHatOfficial.github.io/issues_2018-04-18_2018-04-30' } do
        subject do
          GitHub::Issues.new(org, repo: 'RedHatOfficial.github.io', from: Date.new(2018, 4, 18), to: Date.new(2018, 4, 30), page: 31)
        end

        it 'fetches issues between two dates' do
          expect(subject.labels.keys.sort).to eq ['content request', 'enhancement', 'help wanted', 'on hold', 'pending design feedback']
          expect(subject.labels['enhancement'].count).to eq 1
          expect(subject.labels['on hold'].count).to eq 2
        end
      end
    end
  end

  pending 'repos'
end
