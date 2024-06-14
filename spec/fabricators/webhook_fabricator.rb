# frozen_string_literal: true

Fabricator(:webhook) do
  url { sequence(:url) { |i| "https://example.com/page_#{i}" } }
  secret { SecureRandom.hex }
  events { Webhook::EVENTS }
end
