# frozen_string_literal: true

describe 'project contributors' do
  include_context 'command line'

  context 'stats' do
    it 'returns contributors' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/issues_2022-01-01_2022-01-06 contributors stats --org=RedHatOfficial --from=2022-01-01 --to=2022-01-06`.strip
      expect(output).to include 'total = 1'
      expect(output).to include 'unknown (1)'
    end

    it 'parses date' do
      output = `"#{project}" --no-cache --vcr-cassette-name=search/RedHatOfficial/issues_2022-01-01_2022-01-06 contributors stats --org=RedHatOfficial --from=2022-01-01 --to="january sixth 2022"`.strip
      expect(output).to include 'total = 1'
      expect(output).to include 'unknown (1)'
    end
  end
end
