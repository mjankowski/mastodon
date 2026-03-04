# frozen_string_literal: true

module User::Invitations
  extend ActiveSupport::Concern

  included do
    belongs_to :invite, optional: true
    has_many :invites, inverse_of: :user, dependent: nil
    has_one :invite_request, class_name: 'UserInviteRequest', inverse_of: :user, dependent: :destroy

    validates :invite_request, presence: true, on: :create, if: :invite_text_required?

    accepts_nested_attributes_for :invite_request, reject_if: ->(attributes) { attributes['text'].blank? && !Setting.require_invite_text }

    attr_reader :invite_code

    after_create :increment_invite_uses
  end

  def invited?
    invite_id?
  end

  def valid_invitation?
    invited? && invite.valid_for_use?
  end

  def valid_bypassing_invitation?
    valid_invitation? && invite.bypass_approval?
  end

  def invite_code=(code)
    self.invite = Invite.find_by(code:) if code.present?
    @invite_code = code
  end

  private

  def increment_invite_uses
    invite&.increment!(:uses)
  end

  def invite_text_required?
    Setting.require_invite_text && !open_registrations? && !invite&.bypass_approval? && !external? && !bypass_registration_checks?
  end
end
