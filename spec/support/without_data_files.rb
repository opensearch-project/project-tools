RSpec.shared_context 'without data files' do
  RENAMED_DATA = GitHub::Data.data.chomp('/') + '.tmp'

  before do
    File.rename(GitHub::Data.data, RENAMED_DATA) if File.exist?(GitHub::Data.data)
  end

  after do
    File.rename(RENAMED_DATA, GitHub::Data.data) if File.exist?(RENAMED_DATA)
  end
end
