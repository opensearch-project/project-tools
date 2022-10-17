# frozen_string_literal: true

module GitHub
  module Progress
    class << self
      attr_accessor :enabled
    end

    def progress(options)
      pb = GitHub::Progress.enabled ? ProgressBar.create(options) : OpenStruct.new(increment: nil, finish: nil)
      begin
        yield pb
      ensure
        pb.finish
      end
    end
  end
end
