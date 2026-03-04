# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    validate :validate_role_elevation, if: -> { defined?(@current_account) }
  end

  private

  def validate_role_elevation
    errors.add(:role_id, :elevated) if role&.overrides?(@current_account&.user_role)
  end
end
