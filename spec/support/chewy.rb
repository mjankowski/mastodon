# frozen_string_literal: true

RSpec.configure do |config|
  config.around :each, :search do |example|
    Chewy.settings[:enabled] = true

    # Configure chewy to use `urgent` strategy to index documents
    Chewy.strategy(:urgent) { example.run }

    Chewy.settings[:enabled] = false
  end
end
