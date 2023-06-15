# frozen_string_literal: true

Fabricator(:terms_of_service) do
  text { 'Terms text' }
  changelog { 'Description of change' }
  published_at { Time.zone.now }
  notification_sent_at { Time.zone.now }
end
