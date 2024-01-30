# frozen_string_literal: true

class REST::WebPushSubscriptionSerializer < REST::BaseSerializer
  attributes :id, :endpoint

  attribute :alerts do
    (web_push_subscription.data&.dig('alerts') || {}).each_with_object({}) { |(k, v), h| h[k] = ActiveModel::Type::Boolean.new.cast(v) }
  end

  attribute :server_key do
    Rails.configuration.x.vapid_public_key
  end

  attribute :policy do
    web_push_subscription.data&.dig('policy') || 'all'
  end
end
