# frozen_string_literal: true

describe GitHub::Signers do
  context 'with duplicate emails' do
    subject(:signers) do
      described_class.new([
                            GitHub::Signer.new('dev', 'dev@opensearch.org'),
                            GitHub::Signer.new('Dev Eloper', 'dev@opensearch.org'),
                            GitHub::Signer.new('Dev Eloper, Esq.', 'dev@opensearch.org')
                          ])
    end

    it 'chooses the best name' do
      expect(signers.size).to eq(1)
      expect(signers.first.name).to eq('Dev Eloper, Esq.')
    end
  end

  context 'with noreply email addresses' do
    subject(:signers) do
      described_class.new([
                            GitHub::Signer.new('Mis Configurer', 'noreply@github.com'),
                            GitHub::Signer.new('dev', 'dev@opensearch.org')
                          ])
    end

    it 'sorts noreply email addresses to the end' do
      expect(signers.size).to eq(2)
      expect(signers.sort_for_display.first.email).to eq('dev@opensearch.org')
      expect(signers.sort_for_display.last.email).to eq('noreply@github.com')
    end
  end
end
