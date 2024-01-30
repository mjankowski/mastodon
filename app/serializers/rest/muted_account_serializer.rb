# frozen_string_literal: true

class REST::MutedAccountSerializer < REST::AccountSerializer
  attribute :mute_expires_at do
    mute && !mute.expired? ? mute.expires_at : nil
  end

  private

  def mute
    current_user.account.mute_relationships.find_by(target_account_id: muted_account.id)
  end
end
