# frozen_string_literal: true

module GitHub
  class Commit < Item
    # Creates an array of Signers from all 'Signed-off-by' tags included in the
    # commit message
    def dco_signers
      commit.message.scan(/Signed-off-by: (.+) <([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+)>/).map do |signer|
        Signer.new(signer[0], signer[1])
      end
    end
  end
end
