# frozen_string_literal: true

class REST::Keys::QueryResultSerializer < REST::BaseSerializer
  has_many :devices, serializer: REST::Keys::DeviceSerializer

  attribute :account_id do
    query_result.account.id.to_s
  end
end
