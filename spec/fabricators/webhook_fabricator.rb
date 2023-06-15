# frozen_string_literal: true

Fabricator(:webhook) do
  url { 'https://example.com/webhook' }
  secret { SecureRandom.hex }
  events { Webhook::EVENTS }
end
