# frozen_string_literal: true

module GitHub
  class Signers < Array
    def initialize(arr)
      # De-dupe by email address, choosing the "best" name
      by_email = {}
      arr.each do |signer|
        by_email[signer.email] = best_signer(by_email[signer.email], signer)
      end
      super by_email.values
    end

    # Sort all "noreply" email addresses to the bottom (for manual curation), then sort by name
    def sort_for_display
      Signers.new(sort_by { |signer| [signer.email.include?('noreply') ? 1 : 0, signer.name.downcase] })
    end

    private

    def best_signer(left, right)
      # The "best" name is defined by the name with the most words. For example,
      # if both "dblock" and "Daniel (dB.) Doubrovkine" are encountered, then
      # "Daniel (dB.) Doubrovkine" will be chosen.
      if left.nil? || right.name.split.length > left.name.split.length
        right
      else
        left
      end
    end
  end
end
