# frozen_string_literal: true

describe 'project org' do
  include_context 'command line'

  it 'info' do
    expect(`"#{project}" --no-cache --vcr-cassette-name=orgs/RedHatOfficial org info --org=RedHatOfficial`.strip).to eq [
      'name: Red Hat',
      'description: The official GitHub account for Red Hat (VCR).',
      'url: https://api.github.com/orgs/RedHatOfficial',
      'repos: 83'
    ].join("\n")
  end

  context 'without data files' do
    RENAMED_DATA = GitHub::Data.data.chomp('/') + '.tmp'
    before do
      File.rename(GitHub::Data.data, RENAMED_DATA) if File.exist?(GitHub::Data.data)
    end

    after do
      File.rename(RENAMED_DATA, GitHub::Data.data) if File.exist?(RENAMED_DATA)
    end

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
