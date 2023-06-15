# frozen_string_literal: true

Fabricator(:canonical_email_block) do
  email { sequence(:email) { |i| "email_#{i}@example.com" } }
  reference_account { Fabricate.build(:account) }
end
