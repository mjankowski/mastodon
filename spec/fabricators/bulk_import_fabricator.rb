# frozen_string_literal: true

Fabricator(:bulk_import) do
  account { Fabricate.build(:account) }
  state :scheduled
  type :blocking
end
