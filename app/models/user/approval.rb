# frozen_string_literal: true

module User::Approval
  extend ActiveSupport::Concern

  included do
    scope :approved, -> { where(approved: true) }
    scope :pending, -> { where(approved: false) }

    before_create :set_approved
  end

  def pending?
    !approved?
  end

  def approve!
    return if approved?

    update!(approved: true)

    # Handle condition when approving and confirming at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end

  private

  def set_approved
    self.approved = begin
      if requires_approval?
        false
      else
        open_registrations? || valid_bypassing_invitation? || external?
      end
    end
  end

  def requires_approval?
    sign_up_from_ip_requires_approval? || sign_up_email_requires_approval? || sign_up_username_requires_approval?
  end

  def sign_up_from_ip_requires_approval?
    sign_up_ip? && IpBlock.severity_sign_up_requires_approval.containing(sign_up_ip.to_s).exists?
  end

  def sign_up_email_requires_approval?
    return false if email_domain.blank?

    records = []

    # Doing this conditionally is not very satisfying, but this is consistent
    # with the MX records validations we do and keeps the specs tractable.
    records = DomainResource.new(email_domain).mx unless self.class.skip_mx_check?

    EmailDomainBlock.requires_approval?(records + [email_domain], attempt_ip: sign_up_ip)
  end

  def sign_up_username_requires_approval?
    account.username? && UsernameBlock.matches?(account.username, allow_with_approval: true)
  end
end
