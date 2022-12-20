# frozen_string_literal: true

module GitHub
  class Signer
    attr_reader :email, :name

    def initialize(name, email)
      @name = name
      @email = email
    end

    def to_s
      "#{name},#{email}"
    end
  end
end
