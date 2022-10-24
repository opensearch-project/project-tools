# frozen_string_literal: true

describe 'project pr' do
  include_context 'command line'

  context 'stats' do
    it 'returns contributors' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/prs_2022-01-01_2022-01-06 prs stats --org=RedHatOfficial --from=2022-01-01 --to=2022-01-06 --ignore-unknown`.strip
      expect(output).to include 'Between 2022-01-01 and 2022-01-06, 0% of contributions (0/1) were made by 0 external contributors (0/1).'
    end

    it 'parses dates' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/prs_2022-01-01_2022-01-06 prs stats --org=RedHatOfficial --from=2022-01-01 --to="january sixth 2022" --ignore-unknown`.strip
      expect(output).to include 'Between 2022-01-01 and 2022-01-06, 0% of contributions (0/1) were made by 0 external contributors (0/1).'
    end
  end
end
