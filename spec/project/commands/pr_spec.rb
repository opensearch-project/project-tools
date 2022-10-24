# frozen_string_literal: true

describe 'project pr' do
  include_context 'command line'
  include_context 'without data files'

  context 'stats' do
    it 'returns contributors' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/prs_2022-01-01_2022-01-06 prs stats --org=RedHatOfficial --from=2022-01-01 --to=2022-01-06 --ignore-unknown`.strip
      expect(output).to include 'Between 2022-01-01 and 2022-01-06, 0% of contributions (0/1) were made by 0 external contributors (0/1).'
    end

    it 'parses dates' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/prs_2022-01-01_2022-01-06 prs stats --org=RedHatOfficial --from=2022-01-01 --to="january sixth 2022" --ignore-unknown`.strip
      expect(output).to include 'Between 2022-01-01 and 2022-01-06, 0% of contributions (0/1) were made by 0 external contributors (0/1).'
    end

    it 'returns contributors for the default org' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/opensearch-project/prs_2022-01-01_2022-01-06 prs stats --from=2022-01-01 --to=2022-01-06 --ignore-unknown`.strip
      expect(output).to include 'Between 2022-01-01 and 2022-01-06, 0% of contributions (0/108) were made by 0 external contributors (0/45).'
    end

    it 'returns contributors for a single repo' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/aws/aws-cli/prs_2022-10-01_2022-10-24 prs stats --repo=aws/aws-cli --from=2022-10-01 --to=2022-10-24 --ignore-unknown`.strip
      expect(output).to include 'Between 2022-10-01 and 2022-10-24, 0% of contributions (0/12) were made by 0 external contributors (0/5).'
    end
  end
end
