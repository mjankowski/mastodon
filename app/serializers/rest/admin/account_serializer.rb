# frozen_string_literal: true

class REST::Admin::AccountSerializer < REST::BaseSerializer
  attributes(
    :created_at,
    :domain,
    :username
  )

  has_many :ips, serializer: REST::Admin::IpSerializer
  has_one :account, serializer: REST::AccountSerializer
  has_one :role, serializer: REST::RoleSerializer

  attribute :id do
    account.id.to_s
  end

  attribute :email do
    account.user_email
  end

  attribute :suspended do
    account.suspended?
  end

  attribute :silenced do
    account.silenced?
  end

  attribute :sensitized do
    account.sensitized?
  end

  attribute :confirmed do
    account.user_confirmed?
  end

  attribute :disabled do
    account.user_disabled?
  end

  attribute :approved do
    account.user_approved?
  end

  attribute :locale do
    account.user_locale
  end

  attribute :created_by_application_id, if: :created_by_application? do
    account.user&.created_by_application_id&.to_s&.presence
  end

  attribute :invite_request do
    account.user&.invite_request&.text
  end

  attribute :invited_by_account_id, if: :invited? do
    account.user&.invite&.user&.account_id&.to_s&.presence
  end

  attribute :ip do
    ips&.first&.ip
  end

  protected

  def ips
    account.user&.ips || []
  end

  def role
    account.user_role
  end

  private

  def invited?
    account.user&.invited?
  end

  def created_by_application?
    account.user&.created_by_application_id&.present?
  end
end
