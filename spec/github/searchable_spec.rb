# frozen_string_literal: true

describe GitHub::Searchables do
  {
    { org: 'opensearch-project' } => 'org:opensearch-project',
    { org: %w[opensearch-project aws] } => 'org:opensearch-project org:aws',
    { org: %w[opensearch-project aws], repo: 'aws/aws-cli' } => 'repo:aws/aws-cli org:opensearch-project org:aws',
    { org: %w[opensearch-project aws], repo: ['aws/aws-cli', 'aws/deep-learning-containers'] } => 'repo:aws/aws-cli repo:aws/deep-learning-containers org:opensearch-project org:aws',
    { org: 'opensearch-project', repo: 'OpenSearch' } => 'repo:opensearch-project/OpenSearch',
    { org: 'opensearch-project', repo: %w[OpenSearch OpenSearch-Dashboards] } => 'repo:opensearch-project/OpenSearch repo:opensearch-project/OpenSearch-Dashboards',
    { org: 'opensearch-project', repo: 'aws/aws-cli' } => 'repo:aws/aws-cli org:opensearch-project',
    { org: 'opensearch-project', repo: ['aws/aws-cli', 'aws/deep-learning-containers'] } => 'repo:aws/aws-cli repo:aws/deep-learning-containers org:opensearch-project'
  }.each_pair do |options, s|
    it "#{s}" do
      expect(GitHub::Searchables.new(options).to_s).to eq(s)
    end
  end
  it 'connot combine multiple orgs with a single repo' do
    expect { GitHub::Searchables.new(org: %w[opensearch-project aws], repo: 'repo') }.to raise_error(ArgumentError, "Org name required for 'repo' when multiple orgs are specified.")
  end

  it 'missing org when no org is specified' do
    expect { GitHub::Searchables.new(repo: 'repo') }.to raise_error(ArgumentError, "Org name required for 'repo'.")
  end
end
