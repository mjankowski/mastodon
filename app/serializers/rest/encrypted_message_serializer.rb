# frozen_string_literal: true

class REST::EncryptedMessageSerializer < REST::BaseSerializer
  attributes :type, :body, :digest, :message_franking,
             :created_at

  attribute :id do
    encrypted_message.id.to_s
  end

  attribute :account_id do
    encrypted_message.from_account_id.to_s
  end

  attribute :device_id do
    encrypted_message.from_device_id
  end
end
