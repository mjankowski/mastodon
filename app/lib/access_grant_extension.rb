# frozen_string_literal: true

module AccessGrantExtension
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where.not(expires_in: nil).where(expiration_query) }
    scope :revoked, -> { where.not(revoked_at: nil).where(revoked_at: ...Time.now.utc) }
  end

  class_methods do
    def expiration_query
      Arel.sql(<<~SQL.squish)
        created_at + MAKE_INTERVAL(secs => expires_in) < NOW()
      SQL
    end
  end
end
