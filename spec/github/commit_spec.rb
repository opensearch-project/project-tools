# frozen_string_literal: true

describe GitHub::Commit do
  subject(:commit) do
    message = %{Bump opencensus-contrib-http-util from 0.18.0 to 0.31.1 in /plugins/repository-gcs (#3633)

            * Bump opencensus-contrib-http-util in /plugins/repository-gcs

            Bumps [opencensus-contrib-http-util](https://github.com/census-instrumentation/opencensus-java) from 0.18.0 to 0.31.1.
            - [Release notes](https://github.com/census-instrumentation/opencensus-java/releases)
            - [Changelog](https://github.com/census-instrumentation/opencensus-java/blob/master/CHANGELOG.md)
            - [Commits](census-instrumentation/opencensus-java@v0.18.0...v0.31.1)

            ---
            updated-dependencies:
            - dependency-name: io.opencensus:opencensus-contrib-http-util
              dependency-type: direct:production
              update-type: version-update:semver-minor
            ...

            Signed-off-by: dependabot[bot] <support@github.com>

            * Updating SHAs

            Signed-off-by: dependabot[bot] <support@github.com>

            * Adding missing classes

            Signed-off-by: Vacha Shah <vachshah@amazon.com>

            * changelog change

            Signed-off-by: Poojita Raj <poojiraj@amazon.com>

            Signed-off-by: dependabot[bot] <support@github.com>
            Signed-off-by: Vacha Shah <vachshah@amazon.com>
            Signed-off-by: Poojita Raj <poojiraj@amazon.com>
            Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
            Co-authored-by: dependabot[bot] <dependabot[bot]@users.noreply.github.com>
            Co-authored-by: Vacha Shah <vachshah@amazon.com>
            Co-authored-by: Poojita Raj <poojiraj@amazon.com>
        }
    resource = Sawyer::Resource.new(Sawyer::Agent.new('fake'), { commit: { message: message } })
    described_class.new(resource)
  end

  it 'parses signers from a commit message' do
    expect(commit.dco_signers.count).to eq 7
    expect(commit.dco_signers.map(&:name)).to eq ['dependabot[bot]', 'dependabot[bot]', 'Vacha Shah', 'Poojita Raj', 'dependabot[bot]', 'Vacha Shah', 'Poojita Raj']
  end
end
