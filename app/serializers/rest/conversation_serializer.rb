# frozen_string_literal: true

class REST::ConversationSerializer < REST::BaseSerializer
  attributes :unread

  has_many :participant_accounts, as: :accounts, serializer: REST::AccountSerializer
  has_one :last_status, serializer: REST::StatusSerializer

  def id
    conversation.id.to_s
  end
end
