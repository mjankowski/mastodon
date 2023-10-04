# frozen_string_literal: true

# The devise-two-factor shared example expects Faker to be available
module Faker
  class Lorem
    def self.words
      %w(these are some fake words)
    end
  end
end
