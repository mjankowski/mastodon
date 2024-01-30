# frozen_string_literal: true

class REST::Keys::ClaimResultSerializer < REST::BaseSerializer
  attributes :device_id, :key_id, :key, :signature

  attribute :account_id do
    claim_result.account.id.to_s
  end
end
