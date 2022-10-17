# frozen_string_literal: true

describe 'project org' do
  include_context 'command line'

  it 'info' do
    expect(`"#{project}" --no-cache --vcr-cassette-name=orgs/RedHatOfficial --org RedHatOfficial org info`.strip).to eq [
      'name: Red Hat',
      'description: The official GitHub account for Red Hat (VCR).',
      'url: https://api.github.com/orgs/RedHatOfficial',
      'repos: 83'
    ].join("\n")
  end

  it 'members' do
    expect(`"#{project}" --no-cache --vcr-cassette-name=users/RedHatOfficial --org RedHatOfficial org members`.strip).to eq [
      'org: RedHatOfficial',
      'members: 6',
      'missing in data/users/members.txt: vcr dmc5179 eschabell Fryguy starryeyez024 suehle',
      'no longer members:'
    ].join("\n")
  end
end
