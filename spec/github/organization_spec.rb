# frozen_string_literal: true

describe GitHub::Organization do
  subject do
    GitHub::Organization.new(org: 'RedHatOfficial')
  end

  it 'info', vcr: { cassette_name: 'orgs/RedHatOfficial' } do
    expect(subject.info).to eq [
      'name: Red Hat',
      'description: The official GitHub account for Red Hat (VCR).',
      'url: https://api.github.com/orgs/RedHatOfficial',
      'repos: 83'
    ].join("\n")
  end

  pending 'org'
  pending 'repos'
  pending 'members'
  pending 'pull_requests'
  pending 'issues'
end
