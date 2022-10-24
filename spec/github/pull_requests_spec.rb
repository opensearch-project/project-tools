# frozen_string_literal: true

describe GitHub::PullRequests do
  context 'contributors' do
    context 'org' do
      context 'january 2022', vcr: { cassette_name: 'search/RedHatOfficial/issues_2022-01-01_2022-01-31' } do
        subject do
          GitHub::PullRequests.new(org: 'RedHatOfficial', from: Date.new(2022, 1, 1), to: Date.new(2022, 1, 31), page: 7)
        end

        it 'fetches contributors between two dates' do
          expect(subject.count).to eq 3
          expect(subject.unknown.count).to eq 2
          expect(subject.unknown.map(&:user).map(&:login)).to eq(%w[KushalBeniwal jiekang])
        end
      end
    end

    context 'org + repo' do
      context 'january 2022', vcr: { cassette_name: 'search/multiple/issues_org_and_repo_2022-01-01_2022-01-31' } do
        subject do
          GitHub::PullRequests.new(org: 'RedHatOfficial', repo: 'aws/aws-cli', from: Date.new(2022, 1, 1), to: Date.new(2022, 1, 31), page: 7)
        end

        it 'fetches contributors across an org and an additional repo between two dates' do
          expect(subject.count).to eq 17
        end
      end
    end

    context 'repo' do
      context 'RedHatOfficial.github.io', vcr: { cassette_name: 'search/RedHatOfficial/RedHatOfficial.github.io/issues_2022-09-01_2022-09-31' } do
        subject do
          GitHub::PullRequests.new(org: 'RedHatOfficial', repo: 'RedHatOfficial.github.io', from: Date.new(2022, 9, 1), to: Date.new(2022, 9, 30), page: 31)
        end

        it 'fetches contributors between two dates' do
          expect(subject.count).to eq 5
          expect(subject.unknown.count).to eq 5
          expect(subject.unknown.map(&:user).map(&:login)).to eq(%w[jpopelka razo7 SpyTec SpyTec mscherer])
        end
      end
    end

    context 'repos' do
      context 'mulitple', vcr: { cassette_name: 'search/RedHatOfficial/multiple/issues_2022-01-01_2022-01-30' } do
        subject do
          GitHub::PullRequests.new(org: 'RedHatOfficial', repo: ['GoCourse', 'RedHatOfficial.github.io'], from: from, to: to, page: page)
        end

        let(:from) { Date.new(2022, 1, 1) }
        let(:to) { from + 30 }
        let(:page) { 31 }
        let(:first) { GitHub::PullRequests.new(org: 'RedHatOfficial', repo: ['GoCourse'], from: from, to: to, page: page) }
        let(:second) { GitHub::PullRequests.new(org: 'RedHatOfficial', repo: ['RedHatOfficial.github.io'], from: from, to: to, page: page) }

        it 'fetches contributors' do
          expect(first.count).to eq 1
          expect(second.count).to eq 2
          expect(subject.count).to eq 3
          expect(subject.count).to eq first.count + second.count
        end
      end
    end
  end

  pending 'members'
  pending 'contractors'
  pending 'external'
  pending 'unknown'
  pending '[]'
  pending 'all'
  pending 'internal'
  pending 'all_external'
  pending 'all_external_percent'
end
