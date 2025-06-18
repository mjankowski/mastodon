# frozen_string_literal: true

module AccessGrantExtension
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where.not(expires_in: nil).where(expiration_occured) }
    scope :revoked, -> { where.not(revoked_at: nil).where(revoked_at: ...Time.now.utc) }
  end

  class_methods do
    def expiration_occured
      Arel.sql(<<~SQL.squish)
        created_at + MAKE_INTERVAL(secs => expires_in) < NOW()
      SQL
    end
  end
end
