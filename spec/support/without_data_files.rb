module GitHub::Data
  RENAMED_DATA = GitHub::Data.data.chomp('/') + '.tmp'
end

RSpec.shared_context 'without data files' do
  before do
    File.rename(GitHub::Data.data, GitHub::Data::RENAMED_DATA) if File.exist?(GitHub::Data.data)
  end

  after do
    File.rename(GitHub::Data::RENAMED_DATA, GitHub::Data.data) if File.exist?(GitHub::Data::RENAMED_DATA)
  end
end
