# frozen_string_literal: true

class REST::CredentialAccountSerializer < REST::AccountSerializer
  has_one :role, serializer: REST::RoleSerializer

  attribute :source do
    user = credential_account.user

    {
      privacy: user.setting_default_privacy,
      sensitive: user.setting_default_sensitive,
      language: user.setting_default_language,
      note: credential_account.note,
      fields: credential_account.fields.map(&:to_h),
      follow_requests_count: FollowRequest.where(target_account: credential_account).limit(40).count,
      hide_collections: credential_account.hide_collections,
      discoverable: credential_account.discoverable,
      indexable: credential_account.indexable,
    }
  end

  def role
    credential_account.user_role
  end
end
