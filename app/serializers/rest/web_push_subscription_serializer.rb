# frozen_string_literal: true

class REST::WebPushSubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :endpoint, :standard, :alerts, :server_key, :policy

  delegate :standard, to: :object

  def server_key
    Rails.configuration.x.vapid.public_key
  end

  def policy
    object.policy || 'all'
  end
end
