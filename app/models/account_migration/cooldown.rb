# frozen_string_literal: true

module AccountMigration::Cooldown
  extend ActiveSupport::Concern

  COOLDOWN_PERIOD = 30.days.freeze

  included do
    scope :within_cooldown, -> { where(created_at: cooldown_duration_ago..) }

    validate :validate_migration_cooldown
  end

  class_methods do
    def cooldown_duration_ago
      Time.current - COOLDOWN_PERIOD
    end
  end

  def cooldown_at
    created_at + COOLDOWN_PERIOD
  end

  def remaining_cooldown_days
    ((cooldown_at - Time.current) / 1.day).ceil
  end

  private

  def validate_migration_cooldown
    errors.add(:base, I18n.t('migrations.errors.on_cooldown')) if account.migrations.within_cooldown.exists?
  end
end
