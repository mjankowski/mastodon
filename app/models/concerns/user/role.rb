# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    validate :validate_role_elevation, if: -> { defined?(@current_account) }

    delegate :can?, to: :role

    before_validation :sanitize_role
  end

  class_methods do
    def those_who_can(*any_of_privileges)
      matching_role_ids = UserRole.that_can(*any_of_privileges).map(&:id)

      if matching_role_ids.empty?
        none
      else
        where(role_id: matching_role_ids)
      end
    end
  end

  def role
    if role_id.nil?
      UserRole.everyone
    else
      super
    end
  end

  private

  def sanitize_role
    self.role = nil if role.present? && role.everyone?
  end

  def validate_role_elevation
    errors.add(:role_id, :elevated) if role&.overrides?(@current_account&.user_role)
  end
end
