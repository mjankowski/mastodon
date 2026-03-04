# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    belongs_to :role, class_name: 'UserRole', optional: true

    validate :validate_role_elevation, if: -> { defined?(@current_account) }

    before_validation :sanitize_role

    delegate :can?, to: :role
  end

  class_methods do
    def those_who_can(*privileges)
      UserRole.that_can(*privileges).then do |roles|
        if roles.empty?
          none
        else
          where(role: roles)
        end
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
