# frozen_string_literal: true

describe 'project org' do
  include_context 'command line'
  include_context 'without data files'

  it 'info' do
    expect(`"#{project}" --no-cache --vcr-cassette-name=orgs/RedHatOfficial org info --org=RedHatOfficial`.strip).to eq [
      'name: Red Hat',
      'description: The official GitHub account for Red Hat (VCR).',
      'url: https://api.github.com/orgs/RedHatOfficial',
      'repos: 82'
    ].join("\n")
  end

  context 'teams' do
    it 'returns teams' do
      expect(`"#{project}" --no-cache --vcr-cassette-name=orgs/teams/opensearch-project org teams --org=opensearch-project`.strip).to eq [
        'org: opensearch-project',
        'teams: 2',
        "project-website\t\t1",
        "team 1\tteam one\t0"
      ].join("\n")
    end
  end

  context 'without data files' do
    include_context 'without data files'

    it 'members' do
      expect(`"#{project}" --no-cache --vcr-cassette-name=users/RedHatOfficial org members --org=RedHatOfficial`.strip).to eq [
        'org: RedHatOfficial',
        'members: 6',
        'missing in data/users/members.txt: vcr dmc5179 eschabell Fryguy starryeyez024 suehle',
        'no longer members:'
      ].join("\n")
    end
  end
end
