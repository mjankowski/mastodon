# frozen_string_literal: true

Fabricator(:preview_card) do
  url { sequence(:url) { |i| "https://example.com/page_#{i}" } }
  title { 'A page title' }
  description { 'A description of that page' }
  type 'link'
  image { attachment_fixture('attachment.jpg') }
end
