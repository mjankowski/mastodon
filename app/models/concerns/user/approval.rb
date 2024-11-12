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

    # Handle scenario when approving and confirming a user at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end

  private

  def set_approved
    self.approved = begin
      if sign_up_from_ip_requires_approval? || sign_up_email_requires_approval?
        false
      else
        open_registrations? || valid_invitation? || external?
      end
    end
  end
end
