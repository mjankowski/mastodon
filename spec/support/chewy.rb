# frozen_string_literal: true

RSpec.configure do |config|
  config.around :each, :search do |example|
    # Configure chewy to use `urgent` strategy to index documents
    Chewy.strategy(:urgent) { example.run }
  end
end
