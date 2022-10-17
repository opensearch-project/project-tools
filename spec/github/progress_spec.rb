# frozen_string_literal: true

describe GitHub::Progress do
  subject do
    Class.new do
      extend GitHub::Progress
    end
  end

  context 'when false' do
    it 'is false in specs' do
      expect(GitHub::Progress.enabled).to be false
    end

    it 'yields an OpenStruct' do
      subject.progress({}) do |pb|
        expect(pb).to be_a OpenStruct
      end
    end
  end

  context 'when true' do
    before do
      enabled = GitHub::Progress.enabled
      GitHub::Progress.enabled = true
    end

    after do
      GitHub::Progress.enabled = @enabled
    end

    it 'yields a progress bar' do
      subject.progress({}) do |pb|
        expect(pb).to be_a ProgressBar::Base
      end
    end
  end
end
