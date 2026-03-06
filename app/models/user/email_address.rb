# frozen_string_literal: true

module User::EmailAddress
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, email_address: true

    validates_with UserEmailValidator, if: :validate_user_email?
    validates_with EmailMxValidator, if: :validate_email_dns?

    scope :matches_email, ->(value) { where(arel_table[:email].matches("#{value}%")) }
  end

  class_methods do
    def skip_mx_check?
      Rails.env.local?
    end
  end

  def email_domain
    Mail::Address.new(email).domain
  rescue Mail::Field::ParseError
    nil
  end

  private

  def validate_user_email?
    ENV['EMAIL_DOMAIN_LISTS_APPLY_AFTER_CONFIRMATION'] == 'true' || !confirmed?
  end

  def validate_email_dns?
    email_changed? && !external? && !self.class.skip_mx_check?
  end
end
